import { INestApplication } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import request = require('supertest');
import { createApplication } from '../src/app.factory';

interface VerifiedAccessToken {
  sub: number;
  iat: number;
  exp: number;
  iss: string;
  aud: string;
}

const authDatabaseUrl = requiredEnvironment('AUTH_DATABASE_URL');
const appDatabaseUrl = requiredEnvironment('APP_DATABASE_URL');
const jwtSecret = requiredEnvironment('JWT_SECRET');
const jwtIssuer = requiredEnvironment('JWT_ISSUER');
const jwtAudience = requiredEnvironment('JWT_AUDIENCE');
const loginPassword = requiredEnvironment('AUTH_LOGIN_TEST_PASSWORD');

function requiredEnvironment(name: string): string {
  const value = process.env[name];

  if (value === undefined || value === '') {
    throw new Error(`${name} is required for auth integration tests`);
  }

  return value;
}

describe('Auth login endpoint', () => {
  let app: INestApplication;

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
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('returns a signed 3600-second bearer token for active credentials', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: 'auth-active@example.test', password: loginPassword })
      .expect(200);

    expect(response.body).toEqual({
      accessToken: expect.any(String),
      tokenType: 'Bearer',
      expiresIn: 3600,
    });

    const token = await new JwtService({ secret: jwtSecret }).verifyAsync<VerifiedAccessToken>(
      response.body.accessToken,
      { algorithms: ['HS256'], issuer: jwtIssuer, audience: jwtAudience },
    );
    expect(token).toMatchObject({
      sub: expect.any(Number),
      iss: jwtIssuer,
      aud: jwtAudience,
    });
    expect(token.exp - token.iat).toBe(3600);
  });

  it.each([
    ['wrong password', 'auth-active@example.test', 'wrong-password'],
    ['missing user', 'missing@example.test', loginPassword],
    ['inactive user', 'auth-inactive@example.test', loginPassword],
    ['null password hash', 'auth-null-password@example.test', loginPassword],
  ])('returns generic 401 for %s', async (_scenario, email, password) => {
    const response = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email, password })
      .expect(401);

    expect(response.body.message).toBe('Invalid credentials');
  });

  it('returns 400 for malformed login request', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: 'auth-active@example.test' })
      .expect(400);

    expect(response.body.message).toBe('Invalid login request');
  });
});
