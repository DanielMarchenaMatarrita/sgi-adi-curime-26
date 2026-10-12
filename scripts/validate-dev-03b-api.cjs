#!/usr/bin/env node

const fs = require('node:fs');
const path = require('node:path');

const PROJECT_ROOT = path.resolve(__dirname, '..');
const LOCAL_CONFIG_PATH = path.join(PROJECT_ROOT, '.env.local');
const API_HOST = '127.0.0.1';
const REQUEST_TIMEOUT_MS = 5_000;
const DEV_USERS = Object.freeze([
  { label: '001', email: 'dev1@sgi.invalid' },
  { label: '002', email: 'dev2@sgi.invalid' },
]);

class ValidationFailure extends Error {}

async function main() {
  assertInteractiveTty();
  const baseUrl = resolveLocalApiUrl();
  const passwords = await readPasswords();
  let firstToken = '';
  let secondToken = '';

  try {
    firstToken = await login(DEV_USERS[0], passwords[0], baseUrl);
    passwords[0] = '';
    secondToken = await login(DEV_USERS[1], passwords[1], baseUrl);
    passwords[1] = '';

    await verifyUser001(firstToken, baseUrl);
    await verifyUser002(secondToken, baseUrl);
    await verifyUnauthorizedResponses(baseUrl);
    pass('DEV-03B API validation');
  } finally {
    passwords.fill('');
    firstToken = '';
    secondToken = '';
  }
}

function assertInteractiveTty() {
  if (!process.stdin.isTTY || !process.stdout.isTTY || typeof process.stdin.setRawMode !== 'function') {
    throw new ValidationFailure('interactive TTY required');
  }
}

function resolveLocalApiUrl() {
  let source;
  try {
    source = fs.readFileSync(LOCAL_CONFIG_PATH, 'utf8');
  } catch {
    throw new ValidationFailure('local endpoint configuration unavailable');
  }

  const config = readConfigValues(source, new Set(['NODE_ENV', 'PORT']));
  if (config.NODE_ENV !== 'development') {
    throw new ValidationFailure('local endpoint is not development');
  }

  const port = config.PORT === undefined ? 3000 : Number(config.PORT);
  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new ValidationFailure('local endpoint port invalid');
  }

  return `http://${API_HOST}:${port}`;
}

function readConfigValues(source, names) {
  const values = Object.create(null);
  for (const line of source.split(/\r?\n/u)) {
    const match = /^\s*([A-Z_][A-Z0-9_]*)\s*=\s*([^#\r\n]*)\s*$/u.exec(line);
    if (match === null || !names.has(match[1])) continue;
    if (Object.hasOwn(values, match[1])) {
      throw new ValidationFailure('local endpoint configuration ambiguous');
    }
    values[match[1]] = match[2].trim();
  }
  return values;
}

async function readPasswords() {
  return [
    await readHiddenPassword('DEV-USER-001 password: '),
    await readHiddenPassword('DEV-USER-002 password: '),
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
      else if (password === '') reject(new ValidationFailure('password input empty'));
      else resolve(password);
    };
    const onData = (data) => {
      for (const character of data.toString('utf8')) {
        if (character === '\r' || character === '\n') return finish();
        if (character === '\u0003' || character === '\u0004') return finish(new ValidationFailure('password input cancelled'));
        if (character === '\b' || character === '\u007f') password = password.slice(0, -1);
        else password += character;
      }
    };
    process.stdin.on('data', onData);
  });
}

async function login(user, password, baseUrl) {
  const response = await request(baseUrl, '/api/auth/login', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ email: user.email, password }),
  }, `login-${user.label}`);
  password = '';

  if (response.status === 401) {
    fail(`login-${user.label}: authentication-rejected (HTTP 401)`);
  }
  if (response.status !== 200) {
    fail(`login-${user.label}: HTTP status ${response.status}`);
  }
  const body = response.body;
  if (!isObject(body) || !hasExactKeys(body, ['accessToken', 'expiresIn', 'tokenType']) ||
    typeof body.accessToken !== 'string' || body.accessToken === '' ||
    body.tokenType !== 'Bearer' || !Number.isInteger(body.expiresIn) || body.expiresIn <= 0) {
    fail(`login-${user.label}: response-contract-mismatch`);
  }
  assertJwtExpiryMatchesResponse(
    body.accessToken,
    body.expiresIn,
    `login-${user.label}: token-expiry-mismatch`,
  );
  pass(`login-${user.label}`);
  return body.accessToken;
}

async function verifyUser001(token, baseUrl) {
  const permissions = await request(baseUrl, '/api/users/me/permissions', bearer(token), 'permissions-001');
  if (permissions.status !== 200 || !isObject(permissions.body) || !Array.isArray(permissions.body.permissions) ||
    !permissions.body.permissions.every((permission) => typeof permission === 'string') ||
    !permissions.body.permissions.includes('affiliates.read')) {
    fail('permissions-001');
  }
  pass('permissions-001');

  const active = await request(baseUrl, '/api/affiliates?status=ACTIVE&q=DEV03B&limit=25&offset=0', bearer(token), 'affiliates-active');
  assertAffiliatePage(active, { limit: 25, offset: 0, total: 13, count: 13, status: 'ACTIVE' }, 'affiliates-active');
  assertFixtures(active.body.items, 'affiliates-active', 13);
  pass('affiliates-active');

  const pageOne = await request(baseUrl, '/api/affiliates?q=DEV03B&limit=25&offset=0', bearer(token), 'affiliates-page-1');
  assertAffiliatePage(pageOne, { limit: 25, offset: 0, total: 26, count: 25 }, 'affiliates-page-1');
  const pageTwo = await request(baseUrl, '/api/affiliates?q=DEV03B&limit=25&offset=25', bearer(token), 'affiliates-page-2');
  assertAffiliatePage(pageTwo, { limit: 25, offset: 25, total: 26, count: 1 }, 'affiliates-page-2');
  assertFixtures([...pageOne.body.items, ...pageTwo.body.items], 'affiliates-pages');
  pass('affiliates-pages');
}

async function verifyUser002(token, baseUrl) {
  const response = await request(baseUrl, '/api/affiliates?q=DEV03B&limit=25&offset=0', bearer(token), 'affiliates-002-forbidden');
  if (response.status !== 403 || (isObject(response.body) && Object.hasOwn(response.body, 'items'))) {
    fail('affiliates-002-forbidden');
  }
  pass('affiliates-002-forbidden');
}

async function verifyUnauthorizedResponses(baseUrl) {
  const missing = await request(baseUrl, '/api/users/me/permissions', {}, 'permissions-missing-token');
  const invalid = await request(baseUrl, '/api/users/me/permissions', {
    headers: { authorization: 'Bearer invalid-token' },
  }, 'permissions-invalid-token');
  if (missing.status !== 401) fail('permissions-missing-token');
  if (invalid.status !== 401) fail('permissions-invalid-token');
  pass('permissions-401');
}

function bearer(token) {
  return { headers: { authorization: `Bearer ${token}` } };
}

async function request(baseUrl, requestPath, options, step) {
  let response;
  try {
    response = await fetch(new URL(requestPath, baseUrl), { ...options, signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS) });
  } catch {
    fail(`${step}: network-or-unreachable`);
  }

  let body;
  try {
    body = await response.json();
  } catch {
    fail(`${step}: invalid-or-non-json-response (HTTP ${response.status})`);
  }
  return { status: response.status, body };
}

function assertJwtExpiryMatchesResponse(token, expiresIn, step) {
  const segments = token.split('.');
  if (segments.length !== 3) fail(step);
  let payload;
  try {
    payload = JSON.parse(Buffer.from(segments[1], 'base64url').toString('utf8'));
  } catch {
    fail(step);
  }
  if (
    !isObject(payload) ||
    !Number.isInteger(payload.iat) ||
    !Number.isInteger(payload.exp) ||
    payload.exp <= Math.floor(Date.now() / 1000) ||
    payload.exp - payload.iat !== expiresIn
  ) {
    fail(step);
  }
}

function assertAffiliatePage(response, expected, step) {
  const body = response.body;
  if (response.status !== 200 || !isObject(body) || !hasExactKeys(body, ['items', 'limit', 'offset', 'total']) ||
    !Array.isArray(body.items) || body.limit !== expected.limit || body.offset !== expected.offset ||
    body.total !== expected.total || body.items.length !== expected.count) {
    fail(step);
  }
  if (expected.status !== undefined && body.items.some((item) => !isObject(item) || item.status !== expected.status)) {
    fail(step);
  }
}

function assertFixtures(items, step, expectedCount = 26) {
  if (items.length !== expectedCount) fail(step);
  const expected = new Set(Array.from({ length: expectedCount }, (_, index) => {
    const number = index + 1;
    return `${String(number).padStart(2, '0')}:${number <= 13 ? 'ACTIVE' : 'INACTIVE'}`;
  }));

  for (const item of items) {
    if (!isObject(item) || !hasExactKeys(item, ['affiliateType', 'affiliationDate', 'fullName', 'id', 'status']) ||
      !Number.isInteger(item.id) || item.id < 1 || typeof item.fullName !== 'string' ||
      item.affiliateType !== 'DEV03B' || typeof item.affiliationDate !== 'string' ||
      (item.status !== 'ACTIVE' && item.status !== 'INACTIVE')) {
      fail(step);
    }
    const name = /^DEV03B fixture (\d{2})$/u.exec(item.fullName);
    if (name === null || !expected.delete(`${name[1]}:${item.status}`)) fail(step);
  }
  if (expected.size !== 0) fail(step);
}

function isObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function hasExactKeys(value, keys) {
  const actual = Object.keys(value).sort();
  return actual.length === keys.length && actual.every((key, index) => key === [...keys].sort()[index]);
}

function pass(step) {
  console.log(`PASS ${step}`);
}

function fail(step) {
  throw new ValidationFailure(step);
}

main().catch((error) => {
  const step = error instanceof ValidationFailure ? error.message : 'unexpected-error';
  console.error(`FAIL ${step}`);
  process.exitCode = 1;
});
