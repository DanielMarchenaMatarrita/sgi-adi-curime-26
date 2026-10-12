import { BadRequestException } from '@nestjs/common';
import { AffiliateStatus } from '@prisma/client';

const supportedFields = new Set(['limit', 'offset', 'status', 'q']);

export class ListAffiliatesQueryDto {
  private constructor(
    readonly limit: number,
    readonly offset: number,
    readonly status?: AffiliateStatus,
    readonly q?: string,
  ) {}

  static parse(query: Record<string, unknown>): ListAffiliatesQueryDto {
    if (Object.keys(query).some((field) => !supportedFields.has(field))) {
      throw invalidRequest('Unsupported query parameter');
    }

    const limit = parseLimit(query.limit);
    const offset = parseOffset(query.offset);
    const status = parseStatus(query.status);
    const q = parseOptionalString(query.q, 'q');

    return new ListAffiliatesQueryDto(limit, offset, status, q);
  }
}

function parseLimit(value: unknown): number {
  if (value === undefined) {
    return 25;
  }

  if (typeof value !== 'string' || !/^(?:[1-9]|[1-4][0-9]|50)$/.test(value)) {
    throw invalidRequest('limit must be an integer between 1 and 50');
  }

  return Number(value);
}

function parseOffset(value: unknown): number {
  if (value === undefined) {
    return 0;
  }

  if (typeof value !== 'string' || !/^\d+$/.test(value)) {
    throw invalidRequest('offset must be a non-negative integer');
  }

  const offset = Number(value);
  if (!Number.isSafeInteger(offset)) {
    throw invalidRequest('offset must be a non-negative integer');
  }

  return offset;
}

function parseStatus(value: unknown): AffiliateStatus | undefined {
  if (value === undefined) {
    return undefined;
  }

  if (value === 'ACTIVE' || value === 'INACTIVE') {
    return value;
  }

  throw invalidRequest('status must be ACTIVE or INACTIVE');
}

function parseOptionalString(value: unknown, field: string): string | undefined {
  if (value === undefined) {
    return undefined;
  }

  if (typeof value !== 'string') {
    throw invalidRequest(`${field} must be a string`);
  }

  return value;
}

function invalidRequest(message: string): BadRequestException {
  return new BadRequestException(message);
}
