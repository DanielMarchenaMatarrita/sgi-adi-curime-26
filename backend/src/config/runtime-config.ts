export interface RuntimeConfig {
  nodeEnv: 'development' | 'production' | 'test';
  port: number;
  authDatabaseUrl: string;
  appDatabaseUrl: string;
  jwtSecret: string;
  jwtIssuer: string;
  jwtAudience: string;
}

const validNodeEnvironments = new Set<RuntimeConfig['nodeEnv']>([
  'development',
  'production',
  'test',
]);

export function loadRuntimeConfig(
  environment: NodeJS.ProcessEnv = process.env,
): RuntimeConfig {
  const nodeEnv = environment.NODE_ENV as RuntimeConfig['nodeEnv'];

  if (nodeEnv === undefined || !validNodeEnvironments.has(nodeEnv)) {
    throw new Error('NODE_ENV must be development, production, or test');
  }

  const authDatabaseUrl = requireDatabaseUrl(environment, 'AUTH_DATABASE_URL');
  const appDatabaseUrl = requireDatabaseUrl(environment, 'APP_DATABASE_URL');
  const jwtSecret = requireNonEmpty(environment, 'JWT_SECRET');
  const jwtIssuer = requireNonEmpty(environment, 'JWT_ISSUER');
  const jwtAudience = requireNonEmpty(environment, 'JWT_AUDIENCE');

  if (
    decodeURIComponent(new URL(authDatabaseUrl).username) ===
    decodeURIComponent(new URL(appDatabaseUrl).username)
  ) {
    throw new Error('AUTH_DATABASE_URL and APP_DATABASE_URL must use distinct usernames');
  }

  const rawPort = environment.PORT ?? '3000';
  const port = Number(rawPort);

  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('PORT must be an integer between 1 and 65535');
  }

  return {
    nodeEnv,
    port,
    authDatabaseUrl,
    appDatabaseUrl,
    jwtSecret,
    jwtIssuer,
    jwtAudience,
  };
}

function requireNonEmpty(
  environment: NodeJS.ProcessEnv,
  variableName: 'JWT_SECRET' | 'JWT_ISSUER' | 'JWT_AUDIENCE',
): string {
  const value = environment[variableName];

  if (value === undefined || value.trim() === '') {
    throw new Error(`${variableName} is required`);
  }

  return value;
}

function requireDatabaseUrl(
  environment: NodeJS.ProcessEnv,
  variableName: 'AUTH_DATABASE_URL' | 'APP_DATABASE_URL',
): string {
  const value = environment[variableName];

  if (value === undefined || value.trim() === '') {
    throw new Error(`${variableName} is required`);
  }

  try {
    const url = new URL(value);

    if (url.protocol !== 'postgresql:' && url.protocol !== 'postgres:') {
      throw new Error();
    }
    if (url.username === '') {
      throw new Error();
    }
  } catch {
    throw new Error(`${variableName} must be a valid PostgreSQL URL`);
  }

  return value;
}
