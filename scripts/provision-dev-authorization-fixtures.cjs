#!/usr/bin/env node
'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { PrismaClient } = require('@prisma/client');

const EXPECTED = Object.freeze({ host: '127.0.0.1', port: '5433', database: 'sgi_curime_v2', user: 'sgi_admin' });
const LOCK_KEY = 7362840192853n;
const DEV_USER = Object.freeze({
  identification: 'DEV-USER-002', email: 'dev2@sgi.invalid', firstName: 'Dev',
  firstSurname: 'User002', legacyFullName: 'Synthetic DEV User 002', fullName: 'Synthetic DEV User 002',
});
const DEV_AFFILIATE = Object.freeze({
  identification: 'DEV-AFFILIATE-001', email: 'dev-affiliate-001@sgi.invalid',
  fullName: 'Synthetic DEV Affiliate 001', address: 'Synthetic DEV address', affiliateType: 'DEV',
});

class SafetyStop extends Error {}
const fail = (message) => { throw new SafetyStop(message); };

async function main() {
  const mode = process.argv[2];
  if (!['--check', '--apply'].includes(mode) || process.argv.length !== 3) {
    fail('Uso: node --env-file=.env --env-file=.env.local scripts/provision-dev-authorization-fixtures.cjs --check | --apply');
  }
  if (process.env.NODE_ENV !== 'development') fail('NODE_ENV debe ser development');

  const prisma = new PrismaClient({ datasources: { db: { url: assertTarget(resolveAdminDatabaseUrl(process.env.DATABASE_URL)) } } });
  try {
    const result = await prisma.$transaction(async (tx) => {
      await assertDatabaseIdentity(tx);
      if (mode === '--check') return readState(tx);
      await tx.$executeRaw`SELECT pg_advisory_xact_lock(${LOCK_KEY}::bigint)`;
      return provision(tx);
    }, { isolationLevel: 'Serializable', timeout: 30000 });
    if (mode === '--check') {
      console.log(`CHECK ONLY: DEV-USER-002=${result.user}; DEV-AFFILIATE-001=${result.affiliate}; no se modificó ningún dato.`);
    } else {
      console.log(`PASS DEV authorization fixtures: user=${result.user}; affiliate=${result.affiliate}; user has no roles.`);
    }
  } finally {
    await prisma.$disconnect();
  }
}

function resolveAdminDatabaseUrl(raw) {
  if (!raw) return raw;
  const secretPath = path.join(__dirname, '..', '.env');
  if (!fs.existsSync(secretPath)) return raw;
  const line = fs.readFileSync(secretPath, 'utf8').split(/\r?\n/u).find((entry) => /^SGI_DB_PASSWORD=.+$/u.test(entry));
  if (line === undefined) return raw;
  const url = new URL(raw);
  url.password = line.slice('SGI_DB_PASSWORD='.length).trim();
  return url.toString();
}

function assertTarget(raw) {
  if (!raw) fail('DATABASE_URL ausente');
  let url;
  try { url = new URL(raw); } catch { fail('DATABASE_URL malformada'); }
  if (!['postgres:', 'postgresql:'].includes(url.protocol) || url.hostname !== EXPECTED.host ||
      url.port !== EXPECTED.port || url.pathname !== `/${EXPECTED.database}` ||
      decodeURIComponent(url.username) !== EXPECTED.user) fail('Destino DATABASE_URL no autorizado');
  return raw;
}

async function assertDatabaseIdentity(tx) {
  const rows = await tx.$queryRaw`SELECT current_database() AS database_name, current_user AS user_name`;
  if (rows.length !== 1 || rows[0].database_name !== EXPECTED.database || rows[0].user_name !== EXPECTED.user) {
    fail('Identidad real PostgreSQL distinta de destino autorizado');
  }
}

async function readState(tx) {
  const [user, affiliate] = await Promise.all([
    tx.user.findFirst({ where: { OR: [{ email: DEV_USER.email }, { identification: DEV_USER.identification }] }, select: { id: true } }),
    tx.affiliate.findFirst({ where: { OR: [{ email: DEV_AFFILIATE.email }, { identification: DEV_AFFILIATE.identification }] }, select: { id: true } }),
  ]);
  return { user: user === null ? 'absent' : 'present', affiliate: affiliate === null ? 'absent' : 'present' };
}

async function provision(tx) {
  const person = await ensurePerson(tx);
  const user = await ensureUserWithoutRoles(tx, person.id);
  const affiliate = await ensureAffiliate(tx);
  const roles = await tx.userRole.count({ where: { userId: user.id } });
  if (roles !== 0) fail('DEV-USER-002 tiene roles; transacción revertida');
  return { user: user.action, affiliate };
}

async function ensurePerson(tx) {
  const person = await tx.person.findUnique({ where: { identificationType_normalizedIdentification: { identificationType: 'NATIONAL', normalizedIdentification: DEV_USER.identification } } });
  if (person === null) {
    return tx.person.create({ data: { firstName: DEV_USER.firstName, firstSurname: DEV_USER.firstSurname, legacyFullName: DEV_USER.legacyFullName, identification: DEV_USER.identification, identificationType: 'NATIONAL', normalizedIdentification: DEV_USER.identification, email: DEV_USER.email } });
  }
  if (person.identification !== DEV_USER.identification || person.email !== DEV_USER.email || person.firstName !== DEV_USER.firstName || person.firstSurname !== DEV_USER.firstSurname || person.legacyFullName !== DEV_USER.legacyFullName) fail('Persona DEV-USER-002 existente no coincide; ninguna escritura');
  return person;
}

async function ensureUserWithoutRoles(tx, personId) {
  const users = await tx.user.findMany({ where: { OR: [{ email: DEV_USER.email }, { identification: DEV_USER.identification }, { personId }] } });
  if (users.length === 0) {
    const user = await tx.user.create({ data: { fullName: DEV_USER.fullName, identification: DEV_USER.identification, email: DEV_USER.email, status: 'ACTIVE', personId, identificationType: 'NATIONAL' } });
    return { id: user.id, action: 'created' };
  }
  if (users.length !== 1 || users[0].email !== DEV_USER.email || users[0].identification !== DEV_USER.identification || users[0].personId !== personId || users[0].fullName !== DEV_USER.fullName || users[0].status !== 'ACTIVE' || users[0].passwordHash !== null) fail('Usuario DEV-USER-002 existente no coincide; ninguna escritura');
  return { id: users[0].id, action: 'reused' };
}

async function ensureAffiliate(tx) {
  const affiliates = await tx.affiliate.findMany({ where: { OR: [{ email: DEV_AFFILIATE.email }, { identification: DEV_AFFILIATE.identification }] } });
  if (affiliates.length === 0) {
    await tx.affiliate.create({ data: { fullName: DEV_AFFILIATE.fullName, identification: DEV_AFFILIATE.identification, birthDate: new Date('2000-01-01T00:00:00.000Z'), email: DEV_AFFILIATE.email, address: DEV_AFFILIATE.address, affiliateType: DEV_AFFILIATE.affiliateType, status: 'ACTIVE' } });
    return 'created';
  }
  if (affiliates.length !== 1 || affiliates[0].email !== DEV_AFFILIATE.email || affiliates[0].identification !== DEV_AFFILIATE.identification || affiliates[0].fullName !== DEV_AFFILIATE.fullName || affiliates[0].address !== DEV_AFFILIATE.address || affiliates[0].affiliateType !== DEV_AFFILIATE.affiliateType || affiliates[0].status !== 'ACTIVE' || affiliates[0].personId !== null || affiliates[0].roleId !== null) fail('Afiliado DEV existente no coincide; ninguna escritura');
  return 'reused';
}

main().catch((error) => {
  const message = error instanceof SafetyStop ? error.message : `provisión abortada (${error?.code || error?.name || 'ERROR'})`;
  console.error(`FAIL DEV authorization fixtures: ${message}`);
  process.exitCode = 1;
});
