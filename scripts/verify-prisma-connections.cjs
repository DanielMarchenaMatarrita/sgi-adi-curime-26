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
  } catch {
    console.error(`FAIL ${environmentName}: connection or runtime-role activation failed`);
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
