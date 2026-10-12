#!/usr/bin/env node

const argon2 = require('../backend/node_modules/argon2');
const { PrismaClient } = require('@prisma/client');

const EXPECTED_HOST = '127.0.0.1';
const EXPECTED_PORT = '5433';
const EXPECTED_DATABASE = 'sgi_curime_v2';
const EXPECTED_USER = 'sgi_admin';
const ADVISORY_LOCK_KEY = 7362840192847n;
const IDENTIFICATION_TYPE = 'NATIONAL';
const DEV_USER_001 = Object.freeze({
  identification: 'DEV-USER-001',
  email: 'dev1@sgi.invalid',
});
const DEV_USER_002 = Object.freeze({
  identification: 'DEV-USER-002',
  email: 'dev2@sgi.invalid',
  firstName: 'Dev',
  firstSurname: 'User002',
  legacyFullName: 'Synthetic DEV User 002',
  fullName: 'Synthetic DEV User 002',
});
const AFFILIATES_READ_PERMISSION = 'affiliates.read';

async function main() {
  assertInvocation();
  const databaseUrl = resolveAndValidateDatabaseUrl();
  const passwords = await readPasswords();
  const passwordHashes = await Promise.all(
    passwords.map((password) => argon2.hash(password, { type: argon2.argon2id })),
  );
  passwords.fill('');

  const prisma = new PrismaClient({ datasources: { db: { url: databaseUrl } } });
  try {
    const result = await prisma.$transaction(async (tx) => {
      await tx.$executeRaw`SELECT pg_advisory_xact_lock(${ADVISORY_LOCK_KEY}::bigint)`;
      await assertTransactionTarget(tx);

      const devUser001 = await findExactDevUser001(tx);
      let devUser002 = await findOrAssertDevUser002(tx);
      const resetCount = await tx.$executeRaw`
        UPDATE public."User"
        SET "passwordHash" = ${passwordHashes[0]}
        WHERE "id" = ${devUser001.id}
          AND "identification" = ${DEV_USER_001.identification}
          AND "email" = ${DEV_USER_001.email}
      `;
      if (resetCount !== 1) {
        throw new Error('DEV-USER-001 password reset did not affect exactly one User');
      }

      let createdDevUser002 = false;
      if (devUser002 === null) {
        const person = await tx.person.create({
          data: {
            firstName: DEV_USER_002.firstName,
            firstSurname: DEV_USER_002.firstSurname,
            legacyFullName: DEV_USER_002.legacyFullName,
            identification: DEV_USER_002.identification,
            identificationType: IDENTIFICATION_TYPE,
            normalizedIdentification: DEV_USER_002.identification,
            email: DEV_USER_002.email,
          },
          select: { id: true },
        });
        const user = await tx.user.create({
          data: {
            fullName: DEV_USER_002.fullName,
            identification: DEV_USER_002.identification,
            email: DEV_USER_002.email,
            passwordHash: passwordHashes[1],
            status: 'ACTIVE',
            personId: person.id,
            identificationType: IDENTIFICATION_TYPE,
          },
          select: { id: true },
        });
        devUser002 = { id: user.id, personId: person.id };
        createdDevUser002 = true;
      }

      const verification = await verifyPostWriteState(tx, devUser001, devUser002);
      return { createdDevUser002, ...verification };
    });

    console.log(
      `PASS DEV identities: dev-user-001=password-reset dev-user-002=${
        result.createdDevUser002 ? 'created' : 'verified'
      } effective-permissions=${result.devUser002PermissionCount}`,
    );
  } finally {
    passwordHashes.fill('');
    await prisma.$disconnect();
  }
}

function assertInvocation() {
  if (process.argv.length !== 2) {
    throw new Error('Command-line arguments are not accepted');
  }
  if (process.env.NODE_ENV !== 'development') {
    throw new Error('NODE_ENV must be development');
  }
}

function resolveAndValidateDatabaseUrl() {
  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    throw new Error('DATABASE_URL is required');
  }

  let parsed;
  try {
    parsed = new URL(databaseUrl);
  } catch {
    throw new Error('DATABASE_URL is invalid');
  }
  if (
    !['postgres:', 'postgresql:'].includes(parsed.protocol) ||
    parsed.hostname !== EXPECTED_HOST ||
    parsed.port !== EXPECTED_PORT ||
    parsed.pathname !== `/${EXPECTED_DATABASE}` ||
    parsed.username !== EXPECTED_USER
  ) {
    throw new Error('DATABASE_URL does not target approved development database');
  }
  return databaseUrl;
}

async function readPasswords() {
  if (!process.stdin.isTTY || !process.stdout.isTTY || typeof process.stdin.setRawMode !== 'function') {
    throw new Error('Interactive TTY with hidden password input is required');
  }
  return [
    await readHiddenPassword('DEV-USER-001 new password: '),
    await readHiddenPassword('DEV-USER-002 initial password: '),
  ];
}

function readHiddenPassword(prompt) {
  process.stdout.write(prompt);
  process.stdin.setRawMode(true);
  process.stdin.resume();
  return new Promise((resolve, reject) => {
    let password = '';
    const finish = (error) => {
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
  if (rows[0]?.database_name !== EXPECTED_DATABASE || rows[0]?.user_name !== EXPECTED_USER) {
    throw new Error('Connected database identity is not approved');
  }
}

async function findExactDevUser001(tx) {
  const [byEmail, byIdentification] = await Promise.all([
    tx.user.findUnique({ where: { email: DEV_USER_001.email } }),
    tx.user.findUnique({ where: { identification: DEV_USER_001.identification } }),
  ]);
  if (
    byEmail === null ||
    byIdentification === null ||
    byEmail.id !== byIdentification.id ||
    byEmail.identification !== DEV_USER_001.identification ||
    byIdentification.email !== DEV_USER_001.email
  ) {
    throw new Error('DEV-USER-001 identity is absent or conflicting; no change applied');
  }
  return byEmail;
}

async function findOrAssertDevUser002(tx) {
  const [person, userByEmail, userByIdentification] = await Promise.all([
    tx.person.findUnique({
      where: {
        identificationType_normalizedIdentification: {
          identificationType: IDENTIFICATION_TYPE,
          normalizedIdentification: DEV_USER_002.identification,
        },
      },
    }),
    tx.user.findUnique({ where: { email: DEV_USER_002.email } }),
    tx.user.findUnique({ where: { identification: DEV_USER_002.identification } }),
  ]);
  if (person === null && userByEmail === null && userByIdentification === null) return null;
  if (
    person === null ||
    userByEmail === null ||
    userByIdentification === null ||
    userByEmail.id !== userByIdentification.id ||
    !matchesDevUser002Person(person) ||
    !matchesDevUser002User(userByEmail, person.id)
  ) {
    throw new Error('DEV-USER-002 namespace is nonmatching or partial; no change applied');
  }
  return { id: userByEmail.id, personId: person.id };
}

function matchesDevUser002Person(person) {
  return person.firstName === DEV_USER_002.firstName &&
    person.firstSurname === DEV_USER_002.firstSurname &&
    person.secondSurname === null &&
    person.legacyFullName === DEV_USER_002.legacyFullName &&
    person.identification === DEV_USER_002.identification &&
    person.identificationType === IDENTIFICATION_TYPE &&
    person.normalizedIdentification === DEV_USER_002.identification &&
    person.email === DEV_USER_002.email &&
    person.birthDate === null && person.phoneCountryCode === null &&
    person.phoneNationalNumber === null && person.address === null;
}

function matchesDevUser002User(user, personId) {
  return user.fullName === DEV_USER_002.fullName &&
    user.identification === DEV_USER_002.identification &&
    user.email === DEV_USER_002.email &&
    user.status === 'ACTIVE' && user.personId === personId &&
    user.identificationType === IDENTIFICATION_TYPE && user.phone === null &&
    user.address === null && user.phoneCountryCode === null && user.phoneNationalNumber === null &&
    user.subscriptionExpirationDate === null;
}

async function verifyPostWriteState(tx, devUser001, devUser002) {
  const [devUser001After, devUser002After, roles, permissions] = await Promise.all([
    tx.user.findUnique({ where: { id: devUser001.id } }),
    tx.user.findUnique({ where: { id: devUser002.id } }),
    tx.userRole.findMany({ where: { userId: devUser002.id }, select: { roleId: true } }),
    tx.$queryRaw`
      SELECT DISTINCT p."code"
      FROM public."UserRole" ur
      JOIN public."Role" r ON r."id" = ur."roleId"
      JOIN public."RolePermission" rp ON rp."roleId" = r."id"
      JOIN public."Permission" p ON p."id" = rp."permissionId"
      WHERE ur."userId" = ${devUser002.id}
    `,
  ]);
  if (devUser001After === null || devUser001After.passwordHash === null || !devUser001After.passwordHash.startsWith('$argon2id$')) {
    throw new Error('DEV-USER-001 password hash verification failed');
  }
  if (!matchesPasswordOnlyChange(devUser001, devUser001After)) {
    throw new Error('DEV-USER-001 changed outside passwordHash; transaction rolled back');
  }
  if (devUser002After === null || !matchesDevUser002User(devUser002After, devUser002.personId)) {
    throw new Error('DEV-USER-002 post-write identity verification failed');
  }
  if (roles.length !== 0 || permissions.some((permission) => permission.code === AFFILIATES_READ_PERMISSION)) {
    throw new Error('DEV-USER-002 role or effective permission verification failed');
  }
  return { devUser002PermissionCount: permissions.length };
}

function matchesPasswordOnlyChange(before, after) {
  return Object.keys(before)
    .filter((key) => key !== 'passwordHash')
    .every((key) => {
      const previous = before[key];
      const current = after[key];
      return previous instanceof Date && current instanceof Date
        ? previous.getTime() === current.getTime()
        : previous === current;
    });
}

main().catch((error) => {
  console.error(`FAIL DEV identities: ${error instanceof Error ? error.message : 'unknown error'}`);
  process.exitCode = 1;
});
