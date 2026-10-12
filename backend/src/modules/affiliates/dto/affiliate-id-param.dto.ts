import { BadRequestException } from '@nestjs/common';

export class AffiliateIdParamDto {
  private constructor(readonly affiliateId: number) {}

  static parse(params: Record<string, unknown>): AffiliateIdParamDto {
    if (Object.keys(params).length !== 1 || typeof params.affiliateId !== 'string') {
      throw invalidRequest('affiliateId must be a positive int4');
    }

    const affiliateId = parsePositiveInt4(params.affiliateId);
    if (affiliateId === null) {
      throw invalidRequest('affiliateId must be a positive int4');
    }

    return new AffiliateIdParamDto(affiliateId);
  }
}

function parsePositiveInt4(value: string): number | null {
  if (!/^[1-9][0-9]*$/.test(value)) {
    return null;
  }

  const parsed = Number(value);
  return Number.isSafeInteger(parsed) && parsed <= 2_147_483_647 ? parsed : null;
}

function invalidRequest(message: string): BadRequestException {
  return new BadRequestException(message);
}
