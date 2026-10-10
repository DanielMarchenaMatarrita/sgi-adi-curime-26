import { INestApplication } from '@nestjs/common';
import request = require('supertest');
import { createApplication } from '../src/app.factory';

describe('Health endpoint', () => {
  let app: INestApplication;

  beforeAll(async () => {
    app = await createApplication({ nodeEnv: 'test', port: 3000 });
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET /api/v1/health returns healthy status', async () => {
    await request(app.getHttpServer())
      .get('/api/v1/health')
      .expect(200)
      .expect({ status: 'ok' });
  });
});
