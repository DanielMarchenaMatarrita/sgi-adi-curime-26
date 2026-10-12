import { DynamicModule, Global, Module, Provider } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { RuntimeConfig } from '../config/runtime-config';
import { AppDatabaseService, AuthDatabaseService } from './database.service';
import { APP_PRISMA_CLIENT, AUTH_PRISMA_CLIENT } from './database.tokens';

export { APP_PRISMA_CLIENT, AUTH_PRISMA_CLIENT } from './database.tokens';

@Global()
@Module({})
export class DatabaseModule {
  static register(config: RuntimeConfig): DynamicModule {
    const authClientProvider: Provider = {
      provide: AUTH_PRISMA_CLIENT,
      useFactory: () =>
        new PrismaClient({
          datasources: { db: { url: config.authDatabaseUrl } },
        }),
    };
    const appClientProvider: Provider = {
      provide: APP_PRISMA_CLIENT,
      useFactory: () =>
        new PrismaClient({
          datasources: { db: { url: config.appDatabaseUrl } },
        }),
    };

    return {
      module: DatabaseModule,
      providers: [
        authClientProvider,
        appClientProvider,
        AuthDatabaseService,
        AppDatabaseService,
      ],
      exports: [AuthDatabaseService, AppDatabaseService],
    };
  }
}
