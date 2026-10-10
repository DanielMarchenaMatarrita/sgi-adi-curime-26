import { INestApplication } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { RuntimeConfig } from './config/runtime-config';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';

export async function createApplication(
  config: RuntimeConfig,
): Promise<INestApplication> {
  const app = await NestFactory.create(AppModule.register(config));

  app.setGlobalPrefix('api/v1');
  app.useGlobalFilters(new HttpExceptionFilter());
  app.enableShutdownHooks();

  if (config.nodeEnv === 'development') {
    const document = SwaggerModule.createDocument(
      app,
      new DocumentBuilder().setTitle('SGI API').setVersion('v1').build(),
    );
    SwaggerModule.setup('api/docs', app, document, { useGlobalPrefix: false });
  }

  return app;
}
