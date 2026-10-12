import { INestApplication } from '@nestjs/common';
import request = require('supertest');
import { createApplication } from '../src/app.factory';

describe('Health endpoint', () => {
  let app: INestApplication;

  beforeAll(async () => {
    app = await createApplication({
      nodeEnv: 'test',
      port: 3000,
      authDatabaseUrl: 'postgresql://auth_runtime:secret@localhost:5432/sgi',
      appDatabaseUrl: 'postgresql://app_runtime:secret@localhost:5432/sgi',
      jwtSecret: 'test-secret',
      jwtIssuer: 'sgi-curime-test',
      jwtAudience: 'sgi-curime-test-api',
    });
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET /api/health returns healthy status', async () => {
    await request(app.getHttpServer())
      .get('/api/health')
      .expect(200)
      .expect({ status: 'ok' });
  });
});
