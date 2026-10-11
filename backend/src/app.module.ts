import {
  DynamicModule,
  MiddlewareConsumer,
  Module,
  NestModule,
  RequestMethod,
} from '@nestjs/common';
import { RequestLoggerMiddleware } from './common/middleware/request-logger.middleware';
import { DatabaseModule } from './database/database.module';
import { RuntimeConfig } from './config/runtime-config';
import { HealthModule } from './health/health.module';
import { AuthModule } from './modules/auth/auth.module';

@Module({
})
export class AppModule implements NestModule {
  static register(config: RuntimeConfig): DynamicModule {
    return {
      module: AppModule,
      imports: [HealthModule, DatabaseModule.register(config), AuthModule.register(config)],
    };
  }

  configure(consumer: MiddlewareConsumer): void {
    consumer
      .apply(RequestLoggerMiddleware)
      .forRoutes({ path: '{*path}', method: RequestMethod.ALL });
  }
}