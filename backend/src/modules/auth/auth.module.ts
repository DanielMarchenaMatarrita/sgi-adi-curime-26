import { DynamicModule, Global, Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { RuntimeConfig } from '../../config/runtime-config';
import { AuthController } from './controllers/auth.controller';
import { LoginService } from './features/login/login.service';
import {
  JWT_AUTH_GUARD_OPTIONS,
  JwtAuthGuard,
} from './guards/jwt-auth.guard';
import { PermissionGuard } from './guards/permission.guard';
import { AuthRepository } from './repositories/auth.repository';

@Global()
@Module({})
export class AuthModule {
  static register(config: RuntimeConfig): DynamicModule {
    return {
      module: AuthModule,
      imports: [
        JwtModule.register({
          secret: config.jwtSecret,
          signOptions: {
            algorithm: 'HS256',
            issuer: config.jwtIssuer,
            audience: config.jwtAudience,
            expiresIn: 3600,
          },
        }),
      ],
      controllers: [AuthController],
      providers: [
        AuthRepository,
        LoginService,
        JwtAuthGuard,
        PermissionGuard,
        {
          provide: JWT_AUTH_GUARD_OPTIONS,
          useValue: {
            issuer: config.jwtIssuer,
            audience: config.jwtAudience,
          },
        },
      ],
      exports: [
        JwtModule,
        JwtAuthGuard,
        PermissionGuard,
        JWT_AUTH_GUARD_OPTIONS,
      ],
    };
  }
}
