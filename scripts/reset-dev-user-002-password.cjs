#!/usr/bin/env node

const argon2 = require('../backend/node_modules/argon2');
const { PrismaClient } = require('@prisma/client');

const EXPECTED_HOST = '127.0.0.1';
const EXPECTED_PORT = '5433';
const EXPECTED_DATABASE = 'sgi_curime_v2';
const EXPECTED_USER = 'sgi_admin';
const ADVISORY_LOCK_KEY = 7362840192848n;
const DEV_USER_001 = Object.freeze({
  identification: 'DEV-USER-001',
  email: 'dev1@sgi.invalid',
});
const DEV_USER_002 = Object.freeze({
  identification: 'DEV-USER-002',
  email: 'dev2@sgi.invalid',
});
const AFFILIATES_READ_PERMISSION = 'affiliates.read';

async function main() {
  assertInvocation();
  const databaseUrl = resolveAndValidateDatabaseUrl();
  let password = await readHiddenPassword('DEV-USER-002 new password: ');
  let passwordHash;

  try {
    passwordHash = await argon2.hash(password, { type: argon2.argon2id });
    const prisma = new PrismaClient({ datasources: { db: { url: databaseUrl } } });
    try {
      await prisma.$transaction(async (tx) => {
        await tx.$executeRaw`SELECT pg_advisory_xact_lock(${ADVISORY_LOCK_KEY}::bigint)`;
        await assertTransactionTarget(tx);

        const devUser001Before = await getReadOnlyUserSnapshot(tx, DEV_USER_001);
        const devUser002Before = await findExactUser(tx, DEV_USER_002);
        if (devUser002Before.status !== 'ACTIVE') {
          throw new Error('Target user is not active');
        }

        const updateCount = await tx.$executeRaw`
          UPDATE public."User"
          SET "passwordHash" = ${passwordHash}
          WHERE "id" = ${devUser002Before.id}
            AND "identification" = ${DEV_USER_002.identification}
            AND "email" = ${DEV_USER_002.email}
            AND "status" = 'ACTIVE'
        `;
        if (updateCount !== 1) {
          throw new Error('Password update did not affect exactly one user');
        }

        const devUser002After = await getReadOnlyUserSnapshot(tx, DEV_USER_002);
        await assertTargetPostWriteState(tx, devUser002After, password);
        const devUser001After = await getReadOnlyUserSnapshot(tx, DEV_USER_001);
        assertReadOnlySnapshotUnchanged(devUser001Before, devUser001After);
      });
    } finally {
      await prisma.$disconnect();
    }
  } finally {
    password = '';
    passwordHash = '';
  }

  console.log('PASS DEV-USER-002 password reset');
}

function assertInvocation() {
  if (process.argv.length !== 2) {
    throw new Error('Arguments are not accepted');
  }
  if (process.env.NODE_ENV !== 'development') {
    throw new Error('Development mode is required');
  }
}

function resolveAndValidateDatabaseUrl() {
  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) throw new Error('Database configuration is required');

  let parsed;
  try {
    parsed = new URL(databaseUrl);
  } catch {
    throw new Error('Database configuration is invalid');
  }
  if (
    !['postgres:', 'postgresql:'].includes(parsed.protocol) ||
    parsed.hostname !== EXPECTED_HOST ||
    parsed.port !== EXPECTED_PORT ||
    parsed.pathname !== `/${EXPECTED_DATABASE}` ||
    parsed.username !== EXPECTED_USER
  ) {
    throw new Error('Database target is not approved local development');
  }
  return databaseUrl;
}

function readHiddenPassword(prompt) {
  if (!process.stdin.isTTY || !process.stdout.isTTY || typeof process.stdin.setRawMode !== 'function') {
    throw new Error('Interactive hidden-password TTY is required');
  }

  process.stdout.write(prompt);
  process.stdin.setRawMode(true);
  process.stdin.resume();
  return new Promise((resolve, reject) => {
    let password = '';
    let finished = false;
    const finish = (error) => {
      if (finished) return;
      finished = true;
      process.stdin.off('data', onData);
      process.stdin.setRawMode(false);
      process.stdin.pause();
      process.stdout.write('\n');
      if (error) reject(error);
      else if (password === '') reject(new Error('Password cannot be empty'));
      else resolve(password);
    };
    const onData = (data) => {
      for (const character of data.toString('utf8')) {
        if (character === '\r' || character === '\n') return finish();
        if (character === '\u0003' || character === '\u0004') return finish(new Error('Password prompt cancelled'));
        if (character === '\b' || character === '\u007f') password = password.slice(0, -1);
        else password += character;
      }
    };
    process.stdin.on('data', onData);
  });
}

async function assertTransactionTarget(tx) {
  const rows = await tx.$queryRaw`SELECT current_database() AS database_name, current_user AS user_name`;
  if (rows.length !== 1 || rows[0].database_name !== EXPECTED_DATABASE || rows[0].user_name !== EXPECTED_USER) {
    throw new Error('Connected database identity is not approved');
  }
}

async function findExactUser(tx, identity) {
  const rows = await tx.$queryRaw`
    SELECT "id", "identification", "email", "status"
    FROM public."User"
    WHERE "identification" = ${identity.identification} OR "email" = ${identity.email}
  `;
  if (
    rows.length !== 1 ||
    rows[0].identification !== identity.identification ||
    rows[0].email !== identity.email
  ) {
    throw new Error('Required DEV identity is absent, duplicated, or mismatched');
  }
  return rows[0];
}

async function getReadOnlyUserSnapshot(tx, identity) {
  const user = await findExactUser(tx, identity);
  const [roles, permissions] = await Promise.all([
    tx.userRole.findMany({ where: { userId: user.id }, select: { roleId: true }, orderBy: { roleId: 'asc' } }),
    findEffectivePermissions(tx, user.id),
  ]);
  return {
    id: user.id,
    identification: user.identification,
    email: user.email,
    status: user.status,
    roleIds: roles.map((role) => role.roleId),
    permissionCodes: permissions,
  };
}

async function findEffectivePermissions(tx, userId) {
  const rows = await tx.$queryRaw`
    SELECT DISTINCT p."code"
    FROM public."UserRole" ur
    JOIN public."Role" r ON r."id" = ur."roleId"
    JOIN public."RolePermission" rp ON rp."roleId" = r."id"
    JOIN public."Permission" p ON p."id" = rp."permissionId"
    WHERE ur."userId" = ${userId}
    ORDER BY p."code"
  `;
  return rows.map((row) => row.code);
}

async function assertTargetPostWriteState(tx, snapshot, password) {
  if (snapshot.status !== 'ACTIVE') throw new Error('Target user is not active after update');
  if (snapshot.roleIds.length !== 0 || snapshot.permissionCodes.length !== 0) {
    throw new Error('Target user has roles or effective permissions after update');
  }
  if (snapshot.permissionCodes.includes(AFFILIATES_READ_PERMISSION)) {
    throw new Error('Target user has affiliates.read after update');
  }
  const persisted = await tx.user.findUnique({
    where: { id: snapshot.id },
    select: { passwordHash: true },
  });
  if (!persisted?.passwordHash || !(await argon2.verify(persisted.passwordHash, password))) {
    throw new Error('Persisted password verification failed');
  }
}

function assertReadOnlySnapshotUnchanged(before, after) {
  if (
    before.id !== after.id ||
    before.identification !== after.identification ||
    before.email !== after.email ||
    before.status !== after.status ||
    !sameValues(before.roleIds, after.roleIds) ||
    !sameValues(before.permissionCodes, after.permissionCodes)
  ) {
    throw new Error('DEV-USER-001 changed during reset');
  }
}

function sameValues(left, right) {
  return left.length === right.length && left.every((value, index) => value === right[index]);
}

main().catch(() => {
  console.error('FAIL DEV-USER-002 password reset');
  process.exitCode = 1;
});
