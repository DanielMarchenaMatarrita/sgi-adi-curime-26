import { Controller, Get, INestApplication, Module, UseGuards } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Test } from '@nestjs/testing';
import request = require('supertest');
import { RuntimeConfig } from '../src/config/runtime-config';
import { DatabaseModule } from '../src/database/database.module';
import { AuthModule } from '../src/modules/auth/auth.module';
import { RequirePermissions } from '../src/modules/auth/decorators/require-permissions.decorator';
import { PermissionGuard } from '../src/modules/auth/guards/permission.guard';

jest.setTimeout(20_000);

const config: RuntimeConfig = {
  nodeEnv: 'test',
  port: 3000,
  authDatabaseUrl: requiredEnvironment('AUTH_DATABASE_URL'),
  appDatabaseUrl: requiredEnvironment('APP_DATABASE_URL'),
  jwtSecret: requiredEnvironment('JWT_SECRET'),
  jwtIssuer: requiredEnvironment('JWT_ISSUER'),
  jwtAudience: requiredEnvironment('JWT_AUDIENCE'),
};

function requiredEnvironment(name: string): string {
  const value = process.env[name];
  if (value === undefined || value === '') {
    throw new Error(`${name} is required for permission guard integration tests`);
  }
  return value;
}

@Controller('__test/permission-guard')
@UseGuards(PermissionGuard)
class PermissionGuardTestController {
  @Get('all-of')
  @RequirePermissions('test.rbac.a', 'test.rbac.b')
  allOf(): { status: 'ok' } {
    return { status: 'ok' };
  }

  @Get('authenticated')
  authenticated(): { status: 'ok' } {
    return { status: 'ok' };
  }
}

@Module({
  imports: [DatabaseModule.register(config), AuthModule.register(config)],
  controllers: [PermissionGuardTestController],
})
class PermissionGuardTestModule {}

describe('PermissionGuard', () => {
  let app: INestApplication;
  let jwt: JwtService;

  beforeAll(async () => {
    const module = await Test.createTestingModule({
      imports: [PermissionGuardTestModule],
    }).compile();
    app = module.createNestApplication();
    jwt = new JwtService({
      secret: config.jwtSecret,
      signOptions: {
        algorithm: 'HS256',
        issuer: config.jwtIssuer,
        audience: config.jwtAudience,
      },
    });
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('allows an actor holding every required permission', async () => {
    await request(app.getHttpServer())
      .get('/__test/permission-guard/all-of')
      .set('Authorization', `Bearer ${await tokenFor(1)}`)
      .expect(200)
      .expect({ status: 'ok' });
  });

  it.each([
    ['actor missing all required permissions', 2],
    ['actor with no roles', 3],
  ])('returns 403 for %s', async (_scenario, subject) => {
    await request(app.getHttpServer())
      .get('/__test/permission-guard/all-of')
      .set('Authorization', `Bearer ${await tokenFor(subject)}`)
      .expect(403);
  });

  it.each([
    ['missing bearer header', undefined],
    ['invalid bearer token', 'not-a-jwt'],
  ])('returns 401 for %s', async (_scenario, token) => {
    const testRequest = request(app.getHttpServer()).get(
      '/__test/permission-guard/all-of',
    );
    if (token !== undefined) {
      testRequest.set('Authorization', `Bearer ${token}`);
    }
    await testRequest.expect(401);
  });

  it('allows authenticated access when permission metadata is absent', async () => {
    await request(app.getHttpServer())
      .get('/__test/permission-guard/authenticated')
      .set('Authorization', `Bearer ${await tokenFor(3)}`)
      .expect(200)
      .expect({ status: 'ok' });
  });

  function tokenFor(subject: number): Promise<string> {
    return jwt.signAsync({ sub: subject }, { expiresIn: 60 });
  }
});
