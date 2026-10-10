import { loadRuntimeConfig } from './runtime-config';

const validEnvironment = {
  NODE_ENV: 'test',
  AUTH_DATABASE_URL: 'postgresql://auth_runtime:secret@localhost:5432/sgi',
  APP_DATABASE_URL: 'postgresql://app_runtime:secret@localhost:5432/sgi',
};

describe('loadRuntimeConfig', () => {
  it('requires explicit runtime and isolated database users', () => {
    expect(loadRuntimeConfig(validEnvironment)).toEqual({
      nodeEnv: 'test',
      port: 3000,
      authDatabaseUrl: validEnvironment.AUTH_DATABASE_URL,
      appDatabaseUrl: validEnvironment.APP_DATABASE_URL,
    });
  });

  it.each([
    [{ ...validEnvironment, NODE_ENV: undefined }, 'NODE_ENV'],
    [{ ...validEnvironment, AUTH_DATABASE_URL: undefined }, 'AUTH_DATABASE_URL'],
    [{ ...validEnvironment, APP_DATABASE_URL: 'invalid' }, 'APP_DATABASE_URL'],
    [
      {
        ...validEnvironment,
        APP_DATABASE_URL: 'postgresql://auth_runtime:other@localhost:5432/sgi',
      },
      'distinct usernames',
    ],
  ])('rejects invalid configuration', (environment, message) => {
    expect(() => loadRuntimeConfig(environment)).toThrow(message);
  });

  it('rejects URL-encoded usernames resolving to the same PostgreSQL principal', () => {
    expect(() =>
      loadRuntimeConfig({
        ...validEnvironment,
        AUTH_DATABASE_URL:
          'postgresql://sgi%5Fapp_runtime:secret@localhost:5432/sgi',
        APP_DATABASE_URL:
          'postgresql://sgi_app_runtime:secret@localhost:5432/sgi',
      }),
    ).toThrow('distinct usernames');
  });
});
