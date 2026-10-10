export interface RuntimeConfig {
  nodeEnv: 'development' | 'production' | 'test';
  port: number;
}

const validNodeEnvironments = new Set<RuntimeConfig['nodeEnv']>([
  'development',
  'production',
  'test',
]);

export function loadRuntimeConfig(
  environment: NodeJS.ProcessEnv = process.env,
): RuntimeConfig {
  const nodeEnv = (environment.NODE_ENV ?? 'development') as RuntimeConfig['nodeEnv'];

  if (!validNodeEnvironments.has(nodeEnv)) {
    throw new Error('NODE_ENV must be development, production, or test');
  }

  const rawPort = environment.PORT ?? '3000';
  const port = Number(rawPort);

  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('PORT must be an integer between 1 and 65535');
  }

  return { nodeEnv, port };
}
