import 'reflect-metadata';
import { Logger } from '@nestjs/common';
import { createApplication } from './app.factory';
import { loadRuntimeConfig } from './config/runtime-config';

async function bootstrap(): Promise<void> {
  const config = loadRuntimeConfig();
  const app = await createApplication(config);
  await app.listen(config.port);
}

bootstrap().catch((error: unknown) => {
  const logger = new Logger('Bootstrap');
  logger.error(
    `Application bootstrap failed: ${error instanceof Error ? error.message : 'unknown error'}`,
  );
  process.exitCode = 1;
});
