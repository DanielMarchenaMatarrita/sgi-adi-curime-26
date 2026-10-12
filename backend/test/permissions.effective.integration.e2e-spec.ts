import { INestApplication } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import request = require('supertest');
import { createApplication } from '../src/app.factory';

jest.setTimeout(20_000);

const authDatabaseUrl = requiredEnvironment('AUTH_DATABASE_URL');
const appDatabaseUrl = requiredEnvironment('APP_DATABASE_URL');
const jwtSecret = requiredEnvironment('JWT_SECRET');
const jwtIssuer = requiredEnvironment('JWT_ISSUER');
const jwtAudience = requiredEnvironment('JWT_AUDIENCE');

function requiredEnvironment(name: string): string {
  const value = process.env[name];
  if (value === undefined || value === '') {
    throw new Error(`${name} is required for effective permissions integration tests`);
  }
  return value;
}

describe('GET /api/users/me/permissions', () => {
  let app: INestApplication;
  let jwt: JwtService;

  beforeAll(async () => {
    app = await createApplication({
      nodeEnv: 'test',
      port: 3000,
      authDatabaseUrl,
      appDatabaseUrl,
      jwtSecret,
      jwtIssuer,
      jwtAudience,
    });
    jwt = new JwtService({
      secret: jwtSecret,
      signOptions: { algorithm: 'HS256', issuer: jwtIssuer, audience: jwtAudience },
    });
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('returns actor 1 permissions as exact deduplicated ascending payload', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/users/me/permissions')
      .set('Authorization', `Bearer ${await tokenFor(1)}`)
      .expect(200);

    expect(response.body).toEqual({
      permissions: ['test.rbac.a', 'test.rbac.b', 'test.rbac.shared'],
    });
    console.info(`BE-03C HTTP evidence actor1: ${JSON.stringify(response.body)}`);
  });

  it('isolates actor 2 from actor 1 permissions', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/users/me/permissions')
      .set('Authorization', `Bearer ${await tokenFor(2)}`)
      .expect(200);

    expect(response.body).toEqual({ permissions: ['test.rbac.other'] });
    console.info(`BE-03C HTTP evidence actor2: ${JSON.stringify(response.body)}`);
  });

  it('returns an empty permission set for active actor without roles', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/users/me/permissions')
      .set('Authorization', `Bearer ${await tokenFor(3)}`)
      .expect(200);

    expect(response.body).toEqual({ permissions: [] });
    console.info(`BE-03C HTTP evidence actor3: ${JSON.stringify(response.body)}`);
  });

  it('returns generic 401 for inactive actor', async () => {
    await request(app.getHttpServer())
      .get('/api/users/me/permissions')
      .set('Authorization', `Bearer ${await tokenFor(4)}`)
      .expect(401);
  });

  it.each([
    ['missing bearer header', undefined],
    ['invalid bearer token', 'not-a-jwt'],
    ['expired bearer token', () => tokenFor(1, -1)],
    ['out-of-int4 subject', () => tokenFor(2_147_483_648)],
  ])('returns 401 for %s', async (_scenario, token) => {
    const bearer = typeof token === 'function' ? await token() : token;
    const testRequest = request(app.getHttpServer()).get('/api/users/me/permissions');
    if (bearer !== undefined) {
      testRequest.set('Authorization', `Bearer ${bearer}`);
    }
    await testRequest.expect(401);
  });

  function tokenFor(subject: number, expiresIn = 60): Promise<string> {
    return jwt.signAsync({ sub: subject }, { expiresIn });
  }
});
