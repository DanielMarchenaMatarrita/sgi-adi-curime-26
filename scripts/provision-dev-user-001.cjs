#!/usr/bin/env node
'use strict';

const argon2 = require('../backend/node_modules/argon2');
const { PrismaClient } = require('@prisma/client');
const fs = require('node:fs');
const path = require('node:path');

const EXPECTED = Object.freeze({
  host: '127.0.0.1',
  port: '5433',
  database: 'sgi_curime_v2',
  user: 'sgi_admin',
});
const LOCK_KEY = 7362840192852n;
const DEV_USER = Object.freeze({
  identification: 'DEV-USER-001',
  email: 'dev1@sgi.invalid',
  firstName: 'Dev',
  firstSurname: 'User001',
  legacyFullName: 'Synthetic DEV User 001',
  fullName: 'Synthetic DEV User 001',
  roleName: 'DEV_AFFILIATES_READER',
  permissionCode: 'affiliates.read',
});

class SafetyStop extends Error {}
const fail = (message) => { throw new SafetyStop(message); };

async function main() {
  const mode = process.argv[2];
  if (!['--check', '--apply'].includes(mode) || process.argv.length !== 3) {
    fail('Uso: node --env-file=.env --env-file=.env.local scripts/provision-dev-user-001.cjs --check | --apply');
  }
  if (process.env.NODE_ENV !== 'development') fail('NODE_ENV debe ser development');

  const databaseUrl = assertTarget(resolveAdminDatabaseUrl(process.env.DATABASE_URL));
  const prisma = new PrismaClient({ datasources: { db: { url: databaseUrl } } });
  let password = '';
  let passwordHash = '';

  try {
    if (mode === '--check') {
      const result = await prisma.$transaction(async (tx) => {
        await assertDatabaseIdentity(tx);
        return readState(tx);
      }, { isolationLevel: 'Serializable' });
      console.log(`CHECK ONLY: DEV-USER-001=${result.userState}; role=${result.roleState}; permission=${result.permissionState}; no se modificó ningún dato.`);
      return;
    }

    password = await readAndConfirmPassword();
    passwordHash = await argon2.hash(password, {
      type: argon2.argon2id,
      memoryCost: 65536,
      timeCost: 3,
      parallelism: 1,
    });

    const result = await prisma.$transaction(async (tx) => {
      await tx.$executeRaw`SELECT pg_advisory_xact_lock(${LOCK_KEY}::bigint)`;
      await assertDatabaseIdentity(tx);
      return provision(tx, password, passwordHash);
    }, { isolationLevel: 'Serializable', timeout: 30000 });

    console.log(`PASS DEV-USER-001 provisioned; user=${result.userAction}; role=${result.roleAction}; affiliates.read=linked.`);
  } finally {
    password = '';
    passwordHash = '';
    await prisma.$disconnect();
  }
}

function assertTarget(raw) {
  if (!raw) fail('DATABASE_URL ausente');
  let url;
  try { url = new URL(raw); } catch { fail('DATABASE_URL malformada'); }
  if (
    !['postgres:', 'postgresql:'].includes(url.protocol) ||
    url.hostname !== EXPECTED.host ||
    url.port !== EXPECTED.port ||
    url.pathname !== `/${EXPECTED.database}` ||
    decodeURIComponent(url.username) !== EXPECTED.user
  ) fail('Destino DATABASE_URL no autorizado');
  return raw;
}

function resolveAdminDatabaseUrl(raw) {
  if (!raw) return raw;
  // Local .env.local may retain a stale administrative password while .env
  // stores the current local secret. Read it only in-process; never log it.
  const secretPath = path.join(__dirname, '..', '.env');
  if (!fs.existsSync(secretPath)) return raw;
  const secretLine = fs.readFileSync(secretPath, 'utf8')
    .split(/\r?\n/u)
    .find((line) => /^SGI_DB_PASSWORD=.+$/u.test(line));
  if (secretLine === undefined) return raw;
  const password = secretLine.slice('SGI_DB_PASSWORD='.length).trim();
  if (password === '') return raw;
  const url = new URL(raw);
  url.password = password;
  return url.toString();
}

async function assertDatabaseIdentity(tx) {
  const rows = await tx.$queryRaw`SELECT current_database() AS database_name, current_user AS user_name`;
  if (
    rows.length !== 1 ||
    rows[0].database_name !== EXPECTED.database ||
    rows[0].user_name !== EXPECTED.user
  ) fail('Identidad real PostgreSQL distinta de destino autorizado');
}

async function readState(tx) {
  const [user, role, permission] = await Promise.all([
    tx.user.findFirst({ where: { OR: [{ email: DEV_USER.email }, { identification: DEV_USER.identification }] } }),
    tx.role.findUnique({ where: { name: DEV_USER.roleName } }),
    tx.permission.findUnique({ where: { code: DEV_USER.permissionCode } }),
  ]);
  return {
    userState: user === null ? 'absent' : 'present',
    roleState: role === null ? 'absent' : 'present',
    permissionState: permission === null ? 'absent' : 'present',
  };
}

async function provision(tx, password, passwordHash) {
  const person = await ensurePerson(tx);
  const { user, action: userAction } = await ensureUser(tx, person.id, passwordHash);
  const { role, action: roleAction } = await ensureRole(tx);
  const permission = await ensurePermission(tx);

  await tx.rolePermission.upsert({
    where: { roleId_permissionId: { roleId: role.id, permissionId: permission.id } },
    create: { roleId: role.id, permissionId: permission.id },
    update: {},
  });
  await tx.userRole.upsert({
    where: { userId_roleId: { userId: user.id, roleId: role.id } },
    create: { userId: user.id, roleId: role.id },
    update: {},
  });

  const persisted = await tx.user.findUnique({
    where: { id: user.id },
    select: { id: true, status: true, passwordHash: true },
  });
  if (
    persisted === null ||
    persisted.status !== 'ACTIVE' ||
    !persisted.passwordHash ||
    !(await argon2.verify(persisted.passwordHash, password))
  ) fail('Verificación de usuario DEV falló; transacción revertida');

  const effective = await tx.permission.findMany({
    where: { roles: { some: { role: { users: { some: { userId: user.id } } } } } },
    select: { code: true },
  });
  if (!effective.some((entry) => entry.code === DEV_USER.permissionCode)) {
    fail('Permiso affiliates.read no efectivo; transacción revertida');
  }

  return { userAction, roleAction };
}

async function ensurePerson(tx) {
  const person = await tx.person.findUnique({
    where: {
      identificationType_normalizedIdentification: {
        identificationType: 'NATIONAL',
        normalizedIdentification: DEV_USER.identification,
      },
    },
  });
  if (person === null) {
    return tx.person.create({
      data: {
        firstName: DEV_USER.firstName,
        firstSurname: DEV_USER.firstSurname,
        legacyFullName: DEV_USER.legacyFullName,
        identification: DEV_USER.identification,
        identificationType: 'NATIONAL',
        normalizedIdentification: DEV_USER.identification,
        email: DEV_USER.email,
      },
    });
  }
  if (
    person.identification !== DEV_USER.identification ||
    person.email !== DEV_USER.email ||
    person.firstName !== DEV_USER.firstName ||
    person.firstSurname !== DEV_USER.firstSurname ||
    person.legacyFullName !== DEV_USER.legacyFullName
  ) fail('Persona DEV existente no coincide; ninguna escritura');
  return person;
}

async function ensureUser(tx, personId, passwordHash) {
  const matches = await tx.user.findMany({
    where: { OR: [{ email: DEV_USER.email }, { identification: DEV_USER.identification }, { personId }] },
  });
  if (matches.length === 0) {
    const user = await tx.user.create({
      data: {
        fullName: DEV_USER.fullName,
        identification: DEV_USER.identification,
        email: DEV_USER.email,
        passwordHash,
        status: 'ACTIVE',
        personId,
        identificationType: 'NATIONAL',
      },
    });
    return { user, action: 'created' };
  }
  if (
    matches.length !== 1 ||
    matches[0].email !== DEV_USER.email ||
    matches[0].identification !== DEV_USER.identification ||
    matches[0].personId !== personId ||
    matches[0].fullName !== DEV_USER.fullName ||
    matches[0].status !== 'ACTIVE'
  ) fail('Usuario DEV existente no coincide; ninguna escritura');
  const user = await tx.user.update({ where: { id: matches[0].id }, data: { passwordHash } });
  return { user, action: 'password-reset' };
}

async function ensureRole(tx) {
  const role = await tx.role.findUnique({ where: { name: DEV_USER.roleName } });
  if (role === null) {
    return {
      role: await tx.role.create({
        data: { name: DEV_USER.roleName, description: 'Synthetic local DEV affiliate reader', isActive: true },
      }),
      action: 'created',
    };
  }
  if (!role.isActive) fail('Rol DEV existente no está activo; ninguna escritura');
  return { role, action: 'reused' };
}

async function ensurePermission(tx) {
  const permission = await tx.permission.findUnique({ where: { code: DEV_USER.permissionCode } });
  if (permission !== null) return permission;
  return tx.permission.create({
    data: {
      code: DEV_USER.permissionCode,
      name: 'Read affiliates',
      description: 'Read access for local DEV validation',
    },
  });
}

async function readAndConfirmPassword() {
  const password = await readHiddenPassword('Contraseña DEV-USER-001 (oculta): ');
  const confirmation = await readHiddenPassword('Confirma contraseña DEV-USER-001: ');
  if (password.length < 16) fail('La contraseña debe tener al menos 16 caracteres');
  if (password !== confirmation) fail('Las contraseñas no coinciden');
  return password;
}

function readHiddenPassword(prompt) {
  if (!process.stdin.isTTY || !process.stdout.isTTY || typeof process.stdin.setRawMode !== 'function') {
    fail('Se requiere terminal interactiva para capturar contraseña oculta');
  }
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
      else if (password === '') reject(new SafetyStop('La contraseña no puede ser vacía'));
      else resolve(password);
    };
    const onData = (data) => {
      for (const character of data.toString('utf8')) {
        if (character === '\r' || character === '\n') return finish();
        if (character === '\u0003' || character === '\u0004') return finish(new SafetyStop('Operación cancelada'));
        if (character === '\b' || character === '\u007f') password = password.slice(0, -1);
        else password += character;
      }
    };
    process.stdin.on('data', onData);
  });
}

main().catch((error) => {
  const message = error instanceof SafetyStop
    ? error.message
    : `provisión abortada (${error?.code || error?.name || 'ERROR'})`;
  console.error(`FAIL DEV-USER-001: ${message}`);
  process.exitCode = 1;
});
