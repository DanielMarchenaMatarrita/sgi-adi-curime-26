import { DynamicModule, Module } from '@nestjs/common';
import { RuntimeConfig } from '../../config/runtime-config';
import { UsersController } from './controllers/users.controller';
import { GetCurrentUserService } from './features/get-current-user/get-current-user.service';
import { GetEffectivePermissionsService } from './features/get-effective-permissions/get-effective-permissions.service';
import { UsersRepository } from './repositories/users.repository';

@Module({})
export class UsersModule {
  static register(config: RuntimeConfig): DynamicModule {
    return {
      module: UsersModule,
      controllers: [UsersController],
      providers: [
        UsersRepository,
        GetCurrentUserService,
        GetEffectivePermissionsService,
      ],
    };
  }
}
