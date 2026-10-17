#!/usr/bin/env node

'use strict';

const crypto = require('node:crypto');

const EMAIL = 'dev1@sgi.invalid';
const DEFAULT_PORT = 3000;
const TIMEOUT_MS = 5_000;
const REQUIRED_ENVIRONMENT = [
  'NODE_ENV',
  'JWT_SECRET',
  'JWT_ISSUER',
  'JWT_AUDIENCE',
];

class ValidationFailure extends Error {}

async function main() {
  assertInteractiveTty();
  const config = loadLocalConfig();
  const baseUrl = parseBaseUrl(process.argv.slice(2), config.port);
  let password = await readHiddenPassword('DEV-USER-001 password: ');
  let token = '';

  try {
    token = await login(password, baseUrl, config);
    password = '';
    await verifyMe(token, baseUrl);
    await verifyPermissions(token, baseUrl);
    await verifyAffiliates(token, baseUrl);
    await verifyRejections(baseUrl);
    pass('DEV-USER-001 API validation');
  } finally {
    password = '';
    token = '';
  }
}

function assertInteractiveTty() {
  if (!process.stdin.isTTY || !process.stdout.isTTY || typeof process.stdin.setRawMode !== 'function') {
    throw new ValidationFailure('interactive TTY required');
  }
}

function loadLocalConfig() {
  for (const name of REQUIRED_ENVIRONMENT) {
    if (typeof process.env[name] !== 'string' || process.env[name].trim() === '') {
      throw new ValidationFailure('local runtime configuration unavailable');
    }
  }
  if (process.env.NODE_ENV !== 'development') {
    throw new ValidationFailure('local runtime is not development');
  }

  const rawPort = process.env.PORT ?? String(DEFAULT_PORT);
  const port = Number(rawPort);
  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new ValidationFailure('local runtime port invalid');
  }

  return {
    port,
    jwtSecret: process.env.JWT_SECRET,
    jwtIssuer: process.env.JWT_ISSUER,
    jwtAudience: process.env.JWT_AUDIENCE,
  };
}

function parseBaseUrl(arguments_, defaultPort) {
  if (arguments_.length === 0) return new URL(`http://127.0.0.1:${defaultPort}`);
  if (arguments_.length !== 2 || arguments_[0] !== '--base-url') {
    throw new ValidationFailure('usage: --base-url must be localhost development endpoint');
  }

  let url;
  try {
    url = new URL(arguments_[1]);
  } catch {
    throw new ValidationFailure('base URL invalid');
  }
  if (
    url.protocol !== 'http:' ||
    !['localhost', '127.0.0.1', '[::1]'].includes(url.hostname) ||
    url.username !== '' ||
    url.password !== '' ||
    url.pathname !== '/' ||
    url.search !== '' ||
    url.hash !== ''
  ) {
    throw new ValidationFailure('base URL must be localhost HTTP root without credentials');
  }
  return url;
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

async function login(password, baseUrl, config) {
  const response = await request(baseUrl, '/api/auth/login', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ email: EMAIL, password }),
  }, 'login');

  if (response.status !== 200 || !isExactObject(response.body, ['accessToken', 'expiresIn', 'tokenType']) ||
    typeof response.body.accessToken !== 'string' || response.body.accessToken === '' ||
    response.body.tokenType !== 'Bearer' || response.body.expiresIn !== 3600) {
    fail('login response contract');
  }
  verifyJwt(response.body.accessToken, response.body.expiresIn, config);
  pass('login and JWT signature');
  return response.body.accessToken;
}

function verifyJwt(token, expiresIn, config) {
  const parts = token.split('.');
  if (parts.length !== 3) fail('JWT structure');
  const header = decodeJwtPart(parts[0]);
  const payload = decodeJwtPart(parts[1]);
  if (!isObject(header) || header.alg !== 'HS256' || !isObject(payload) ||
    !Number.isSafeInteger(payload.sub) || payload.sub < 1 ||
    !Number.isSafeInteger(payload.iat) || !Number.isSafeInteger(payload.exp) ||
    payload.exp - payload.iat !== expiresIn || payload.exp <= Math.floor(Date.now() / 1000) ||
    payload.iss !== config.jwtIssuer || !hasAudience(payload.aud, config.jwtAudience)) {
    fail('JWT claims');
  }
  const expectedSignature = crypto.createHmac('sha256', config.jwtSecret).update(`${parts[0]}.${parts[1]}`).digest();
  let actualSignature;
  try {
    actualSignature = Buffer.from(parts[2], 'base64url');
  } catch {
    fail('JWT signature');
  }
  if (actualSignature.length !== expectedSignature.length || !crypto.timingSafeEqual(actualSignature, expectedSignature)) {
    fail('JWT signature');
  }
}

function decodeJwtPart(part) {
  try {
    return JSON.parse(Buffer.from(part, 'base64url').toString('utf8'));
  } catch {
    fail('JWT encoding');
  }
}

function hasAudience(audience, expected) {
  return audience === expected || (Array.isArray(audience) && audience.includes(expected));
}

async function verifyMe(token, baseUrl) {
  const response = await request(baseUrl, '/api/users/me', bearer(token), 'users me');
  if (response.status !== 200 || !isExactObject(response.body, ['email', 'fullName', 'id', 'status']) ||
    !Number.isSafeInteger(response.body.id) || response.body.id < 1 ||
    typeof response.body.fullName !== 'string' || response.body.fullName === '' ||
    response.body.email !== EMAIL || response.body.status !== 'ACTIVE') {
    fail('users me response contract');
  }
  pass('users me');
}

async function verifyPermissions(token, baseUrl) {
  const response = await request(baseUrl, '/api/users/me/permissions', bearer(token), 'permissions');
  if (response.status !== 200 || !isExactObject(response.body, ['permissions']) ||
    !Array.isArray(response.body.permissions) || !response.body.permissions.every((value) => typeof value === 'string') ||
    !response.body.permissions.includes('affiliates.read')) {
    fail('permissions response contract');
  }
  pass('permissions affiliates.read');
}

async function verifyAffiliates(token, baseUrl) {
  const first = await request(baseUrl, '/api/affiliates?limit=1&offset=0', bearer(token), 'affiliates first page');
  assertAffiliatePage(first, 1, 0);
  if (first.body.total > 1) {
    const second = await request(baseUrl, '/api/affiliates?limit=1&offset=1', bearer(token), 'affiliates second page');
    assertAffiliatePage(second, 1, 1, first.body.total);
  }
  pass('affiliates pagination');
}

function assertAffiliatePage(response, limit, offset, expectedTotal) {
  const body = response.body;
  if (response.status !== 200 || !isExactObject(body, ['items', 'limit', 'offset', 'total']) ||
    !Array.isArray(body.items) || body.limit !== limit || body.offset !== offset ||
    !Number.isSafeInteger(body.total) || body.total < 0 ||
    (expectedTotal !== undefined && body.total !== expectedTotal) ||
    body.items.length !== Math.min(limit, Math.max(0, body.total - offset))) {
    fail('affiliates pagination contract');
  }
  for (const item of body.items) {
    if (!isExactObject(item, ['affiliateType', 'affiliationDate', 'fullName', 'id', 'status']) ||
      !Number.isSafeInteger(item.id) || item.id < 1 || typeof item.fullName !== 'string' ||
      !(typeof item.affiliateType === 'string' || item.affiliateType === null) ||
      typeof item.affiliationDate !== 'string' || !['ACTIVE', 'INACTIVE'].includes(item.status)) {
      fail('affiliates item contract');
    }
  }
}

async function verifyRejections(baseUrl) {
  for (const path of ['/api/users/me', '/api/users/me/permissions', '/api/affiliates']) {
    const missing = await request(baseUrl, path, {}, 'missing token');
    const invalid = await request(baseUrl, path, { headers: { authorization: 'Bearer invalid-token' } }, 'invalid token');
    if (missing.status !== 401 || invalid.status !== 401) fail('protected endpoint rejection');
  }
  pass('missing and invalid token rejection');
}

function bearer(token) {
  return { headers: { authorization: `Bearer ${token}` } };
}

async function request(baseUrl, requestPath, options, step) {
  let response;
  try {
    response = await fetch(new URL(requestPath, baseUrl), { ...options, signal: AbortSignal.timeout(TIMEOUT_MS) });
  } catch {
    fail(`${step} unreachable`);
  }
  let body;
  try {
    body = await response.json();
  } catch {
    fail(`${step} non-JSON response`);
  }
  return { status: response.status, body };
}

function isObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function isExactObject(value, keys) {
  if (!isObject(value)) return false;
  const actual = Object.keys(value).sort();
  const expected = [...keys].sort();
  return actual.length === expected.length && actual.every((key, index) => key === expected[index]);
}

function pass(step) {
  console.log(`PASS ${step}`);
}

function fail(step) {
  throw new ValidationFailure(step);
}

main().catch((error) => {
  console.error(`FAIL ${error instanceof ValidationFailure ? error.message : 'unexpected error'}`);
  process.exitCode = 1;
});
