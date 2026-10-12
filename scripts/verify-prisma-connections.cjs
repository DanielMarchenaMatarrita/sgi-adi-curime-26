const { PrismaClient } = require('@prisma/client');

const targets = [
  { environmentName: 'AUTH_DATABASE_URL', role: 'sgi_auth_runtime' },
  { environmentName: 'APP_DATABASE_URL', role: 'sgi_app_runtime' },
];

async function verify({ environmentName, role }) {
  const url = process.env[environmentName];
  if (!url || url.trim() === '') {
    throw new Error(`${environmentName} is required`);
  }

  const client = new PrismaClient({ datasources: { db: { url } } });
  try {
    try {
      await client.$connect();
    } catch (error) {
      const code =
        typeof error?.code === 'string'
          ? error.code
          : typeof error?.errorCode === 'string'
            ? error.errorCode
            : 'UNKNOWN';
      const category =
        code === 'P1000'
          ? 'authentication rejected'
          : code === 'P1001' || code === 'P1002'
            ? 'database unreachable or timed out'
            : code === 'P1011'
              ? 'TLS connection failed'
              : 'connection failed';
      console.error(`FAIL ${environmentName}: ${category} (${code})`);
      process.exitCode = 1;
      return;
    }

    const identity = await client.$transaction(async (tx) => {
      if (role === 'sgi_auth_runtime') {
        await tx.$executeRaw`SET LOCAL ROLE sgi_auth_runtime`;
      } else {
        await tx.$executeRaw`SET LOCAL ROLE sgi_app_runtime`;
      }
      const rows = await tx.$queryRaw`SELECT current_user, current_role`;
      return rows[0];
    });

    if (identity.current_user !== role || identity.current_role !== role) {
      throw new Error('runtime role did not activate');
    }
    console.log(`PASS ${environmentName}: ${role}`);
  } catch (error) {
    const code =
      typeof error?.code === 'string'
        ? error.code
        : typeof error?.errorCode === 'string'
          ? error.errorCode
          : 'UNKNOWN';
    console.error(
      `FAIL ${environmentName}: SET ROLE or runtime identity validation failed (${code})`,
    );
    process.exitCode = 1;
  } finally {
    await client.$disconnect();
  }
}

async function main() {
  for (const target of targets) {
    await verify(target);
  }
}

main().catch((error) => {
  console.error(`FAIL Prisma validation: ${error.message}`);
  process.exitCode = 1;
});
