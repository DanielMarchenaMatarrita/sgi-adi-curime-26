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
    throw new Error(`${name} is required for affiliates integration tests`);
  }
  return value;
}

describe('GET /api/affiliates', () => {
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

  it('returns only contract fields and applies status, q, limit, and offset', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/affiliates')
      .query({ status: 'ACTIVE', q: 'affiliate', limit: 1, offset: 0 })
      .set('Authorization', `Bearer ${await tokenFor(1)}`)
      .expect(200);

    expect(response.body).toEqual({
      items: [
        {
          id: expect.any(Number),
          fullName: 'Affiliate Active',
          affiliateType: 'REGULAR',
          affiliationDate: '2020-01-01T00:00:00.000Z',
          status: 'ACTIVE',
        },
      ],
      limit: 1,
      offset: 0,
      total: 1,
    });
  });

  it('returns one contract-projected affiliate detail', async () => {
    const list = await request(app.getHttpServer())
      .get('/api/affiliates')
      .query({ status: 'INACTIVE' })
      .set('Authorization', `Bearer ${await tokenFor(1)}`)
      .expect(200);

    const response = await request(app.getHttpServer())
      .get(`/api/affiliates/${list.body.items[0].id}`)
      .set('Authorization', `Bearer ${await tokenFor(1)}`)
      .expect(200);

    expect(response.body).toEqual({
      id: list.body.items[0].id,
      fullName: 'Affiliate Inactive',
      affiliateType: null,
      affiliationDate: '2021-01-01T00:00:00.000Z',
      status: 'INACTIVE',
    });
  });

  it.each([
    ['/api/affiliates?limit=0', 'limit below range'],
    ['/api/affiliates?offset=-1', 'negative offset'],
    ['/api/affiliates?status=BLOCKED', 'invalid status'],
    ['/api/affiliates/not-an-id', 'invalid identifier'],
  ])('returns 400 for %s (%s)', async (path) => {
    await request(app.getHttpServer())
      .get(path)
      .set('Authorization', `Bearer ${await tokenFor(1)}`)
      .expect(400);
  });

  it('returns 404 when permitted actor requests a missing affiliate', async () => {
    await request(app.getHttpServer())
      .get('/api/affiliates/2147483647')
      .set('Authorization', `Bearer ${await tokenFor(1)}`)
      .expect(404);
  });

  it('returns 403 without affiliates.read', async () => {
    await request(app.getHttpServer())
      .get('/api/affiliates')
      .set('Authorization', `Bearer ${await tokenFor(2)}`)
      .expect(403);
  });

  function tokenFor(subject: number): Promise<string> {
    return jwt.signAsync({ sub: subject }, { expiresIn: 60 });
  }
});
