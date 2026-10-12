#!/usr/bin/env node

const { PrismaClient } = require('@prisma/client');

const EXPECTED_HOST = '127.0.0.1';
const EXPECTED_PORT = '5433';
const EXPECTED_DATABASE = 'sgi_curime_v2';
const EXPECTED_USER = 'sgi_admin';
const CONFIRMATION_VALUE = 'sgi_curime_v2';
const ADVISORY_LOCK_KEY = 7362840192846n;
const IDENTIFICATION_TYPE = 'NATIONAL';

const fixtures = Array.from({ length: 26 }, (_, index) => {
  const number = index + 1;
  const day = String(number).padStart(2, '0');
  const identification = `DEV03B-AFF-${day}`;

  return {
    identification,
    firstName: 'DEV03B',
    firstSurname: `FIXTURE-${day}`,
    legacyFullName: `DEV03B fixture ${day}`,
    birthDate: new Date(`2000-01-${day}T00:00:00.000Z`),
    address: 'DEV03B synthetic fixture',
    fullName: `DEV03B fixture ${day}`,
    affiliateType: 'DEV03B',
    affiliationDate: new Date(`2020-01-${day}T00:00:00.000Z`),
    status: number <= 13 ? 'ACTIVE' : 'INACTIVE',
  };
});

async function main() {
  assertInvocation();
  const databaseUrl = resolveAndValidateDatabaseUrl();
  const prisma = new PrismaClient({ datasources: { db: { url: databaseUrl } } });

  try {
    const result = await prisma.$transaction(async (tx) => {
      await tx.$executeRaw`SELECT pg_advisory_xact_lock(${ADVISORY_LOCK_KEY}::bigint)`;
      await assertTransactionTarget(tx);

      const [persons, affiliates] = await Promise.all([
        tx.person.findMany({
          where: {
            normalizedIdentification: { in: fixtures.map((fixture) => fixture.identification) },
          },
          select: {
            id: true,
            firstName: true,
            firstSurname: true,
            secondSurname: true,
            legacyFullName: true,
            identification: true,
            identificationType: true,
            normalizedIdentification: true,
            birthDate: true,
            email: true,
            phoneCountryCode: true,
            phoneNationalNumber: true,
            address: true,
          },
        }),
        tx.affiliate.findMany({
          where: { identification: { in: fixtures.map((fixture) => fixture.identification) } },
          select: {
            fullName: true,
            identification: true,
            birthDate: true,
            gender: true,
            phone: true,
            email: true,
            address: true,
            occupation: true,
            workplace: true,
            affiliateType: true,
            affiliationDate: true,
            status: true,
            identificationType: true,
            phoneCountryCode: true,
            phoneNationalNumber: true,
            personId: true,
            roleId: true,
          },
        }),
      ]);

      if (persons.length === 0 && affiliates.length === 0) {
        const now = new Date();
        const createdPersons = [];

        for (const fixture of fixtures) {
          createdPersons.push(
            await tx.person.create({
              data: {
                firstName: fixture.firstName,
                firstSurname: fixture.firstSurname,
                legacyFullName: fixture.legacyFullName,
                identification: fixture.identification,
                identificationType: IDENTIFICATION_TYPE,
                normalizedIdentification: fixture.identification,
                birthDate: fixture.birthDate,
                address: fixture.address,
                updatedAt: now,
              },
              select: { id: true },
            }),
          );
        }

        for (let index = 0; index < fixtures.length; index += 1) {
          const fixture = fixtures[index];
          await tx.affiliate.create({
            data: {
              fullName: fixture.fullName,
              identification: fixture.identification,
              birthDate: fixture.birthDate,
              address: fixture.address,
              affiliateType: fixture.affiliateType,
              affiliationDate: fixture.affiliationDate,
              status: fixture.status,
              identificationType: IDENTIFICATION_TYPE,
              personId: createdPersons[index].id,
              updatedAt: now,
            },
          });
        }

        return { action: 'created', persons: fixtures.length, affiliates: fixtures.length };
      }

      if (persons.length !== fixtures.length || affiliates.length !== fixtures.length) {
        throw new Error('Fixture namespace is partial, divided, or conflicting');
      }

      assertValidRerun(persons, affiliates);
      return { action: 'noop', persons: 0, affiliates: 0 };
    });

    console.log(`PASS DEV affiliate fixtures: ${result.action} persons=${result.persons} affiliates=${result.affiliates}`);
  } finally {
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
  if (process.env.DEV_FIXTURE_CONFIRM !== CONFIRMATION_VALUE) {
    throw new Error('DEV_FIXTURE_CONFIRM is invalid');
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

async function assertTransactionTarget(tx) {
  const rows = await tx.$queryRaw`
    SELECT current_database() AS database_name, current_user AS user_name
  `;
  const identity = rows[0];

  if (identity?.database_name !== EXPECTED_DATABASE || identity?.user_name !== EXPECTED_USER) {
    throw new Error('Connected database identity is not approved');
  }
}

function assertValidRerun(persons, affiliates) {
  const personsByIdentification = new Map(
    persons.map((person) => [person.normalizedIdentification, person]),
  );
  const affiliatesByIdentification = new Map(
    affiliates.map((affiliate) => [affiliate.identification, affiliate]),
  );

  for (const fixture of fixtures) {
    const person = personsByIdentification.get(fixture.identification);
    const affiliate = affiliatesByIdentification.get(fixture.identification);

    if (!matchesPerson(person, fixture) || !matchesAffiliate(affiliate, person.id, fixture)) {
      throw new Error('Fixture namespace does not match deterministic contract');
    }
  }
}

function matchesPerson(person, fixture) {
  return (
    person !== undefined &&
    person.firstName === fixture.firstName &&
    person.firstSurname === fixture.firstSurname &&
    person.secondSurname === null &&
    person.legacyFullName === fixture.legacyFullName &&
    person.identification === fixture.identification &&
    person.identificationType === IDENTIFICATION_TYPE &&
    person.normalizedIdentification === fixture.identification &&
    sameTimestamp(person.birthDate, fixture.birthDate) &&
    person.email === null &&
    person.phoneCountryCode === null &&
    person.phoneNationalNumber === null &&
    person.address === fixture.address
  );
}

function matchesAffiliate(affiliate, personId, fixture) {
  return (
    affiliate !== undefined &&
    affiliate.fullName === fixture.fullName &&
    affiliate.identification === fixture.identification &&
    sameTimestamp(affiliate.birthDate, fixture.birthDate) &&
    affiliate.gender === null &&
    affiliate.phone === null &&
    affiliate.email === null &&
    affiliate.address === fixture.address &&
    affiliate.occupation === null &&
    affiliate.workplace === null &&
    affiliate.affiliateType === fixture.affiliateType &&
    sameTimestamp(affiliate.affiliationDate, fixture.affiliationDate) &&
    affiliate.status === fixture.status &&
    affiliate.identificationType === IDENTIFICATION_TYPE &&
    affiliate.phoneCountryCode === null &&
    affiliate.phoneNationalNumber === null &&
    affiliate.personId === personId &&
    affiliate.roleId === null
  );
}

function sameTimestamp(actual, expected) {
  return actual instanceof Date && actual.getTime() === expected.getTime();
}

main().catch((error) => {
  console.error('FAIL DEV affiliate fixtures:', error.message);
  process.exitCode = 1;
});