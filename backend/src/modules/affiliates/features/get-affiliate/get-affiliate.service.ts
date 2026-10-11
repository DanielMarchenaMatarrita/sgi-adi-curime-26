import { Injectable, NotFoundException } from '@nestjs/common';
import { AffiliateStatus } from '@prisma/client';
import { Affiliate, AffiliatesRepository } from '../../repositories/affiliates.repository';

export interface AffiliateResponse {
  id: number;
  fullName: string;
  affiliateType: string | null;
  affiliationDate: Date;
  status: AffiliateStatus;
}

@Injectable()
export class GetAffiliateService {
  constructor(private readonly affiliatesRepository: AffiliatesRepository) {}

  async execute(actorUserId: number, affiliateId: number): Promise<AffiliateResponse> {
    const affiliate = await this.affiliatesRepository.findById(actorUserId, affiliateId);
    if (affiliate === null) {
      throw new NotFoundException('Affiliate not found');
    }

    return toResponse(affiliate);
  }
}

export function toResponse(affiliate: Affiliate): AffiliateResponse {
  return {
    id: affiliate.id,
    fullName: affiliate.fullName,
    affiliateType: affiliate.affiliateType,
    affiliationDate: affiliate.affiliationDate,
    status: affiliate.status,
  };
}
