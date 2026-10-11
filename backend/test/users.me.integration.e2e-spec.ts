import { INestApplication } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import request = require('supertest');
import { createApplication } from '../src/app.factory';
import { AppDatabaseService } from '../src/database/database.service';

const authDatabaseUrl = requiredEnvironment('AUTH_DATABASE_URL');
const appDatabaseUrl = requiredEnvironment('APP_DATABASE_URL');
const jwtSecret = requiredEnvironment('JWT_SECRET');
const jwtIssuer = requiredEnvironment('JWT_ISSUER');
const jwtAudience = requiredEnvironment('JWT_AUDIENCE');

function requiredEnvironment(name: string): string {
  const value = process.env[name];
  if (value === undefined || value === '') {
    throw new Error(`${name} is required for users integration tests`);
  }
  return value;
}

describe('GET /api/users/me', () => {
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

  it('returns exactly permitted fields for active actor', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/users/me')
      .set('Authorization', `Bearer ${await tokenFor(1)}`)
      .expect(200);

    expect(response.body).toEqual({
      id: 1,
      fullName: 'Ana Example',
      email: 'ana@example.test',
      status: 'ACTIVE',
    });

  });

  it.each([
    ['missing bearer header', undefined],
    ['invalid bearer token', 'not-a-jwt'],
    ['expired bearer token', () => tokenFor(1, -1)],
  ])('returns 401 for %s', async (_scenario, token) => {
    const bearer = typeof token === 'function' ? await token() : token;
    const testRequest = request(app.getHttpServer()).get('/api/users/me');
    if (bearer !== undefined) {
      testRequest.set('Authorization', `Bearer ${bearer}`);
    }
    await testRequest.expect(401);
  });

  it.each([
    ['non-int4 subject', 2_147_483_648],
    ['inactive subject', 4],
    ['blocked subject', 6],
    ['nonexistent subject', 2_147_483_647],
  ])('returns 401 without revealing %s', async (_scenario, subject) => {
    await request(app.getHttpServer())
      .get('/api/users/me')
      .set('Authorization', `Bearer ${await tokenFor(subject)}`)
      .expect(401);
  });

  it('keeps RLS identity reads isolated between actors', async () => {
    const [ana, bruno] = await Promise.all(
      [1, 2].map(async (subject) =>
        request(app.getHttpServer())
          .get('/api/users/me')
          .set('Authorization', `Bearer ${await tokenFor(subject)}`)
          .expect(200),
      ),
    );

    expect(ana.body.id).toBe(1);
    expect(ana.body.email).toBe('ana@example.test');
    expect(bruno.body.id).toBe(2);
    expect(bruno.body.email).toBe('bruno@example.test');
  });

  it('does not receive ungranted User columns through app runtime', async () => {
    const appDatabase = app.get(AppDatabaseService);

    await expect(
      appDatabase.withActor(1, (tx) =>
        tx.$queryRaw`SELECT "identification" FROM public."User"`,
      ),
    ).rejects.toMatchObject({ meta: { code: '42501' } });
  });

  function tokenFor(subject: number, expiresIn = 60): Promise<string> {
    return jwt.signAsync({ sub: subject }, { expiresIn });
  }
});
