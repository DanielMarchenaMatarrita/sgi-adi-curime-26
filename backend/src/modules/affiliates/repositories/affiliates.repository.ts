import { Injectable } from '@nestjs/common';
import { AffiliateStatus, Prisma } from '@prisma/client';
import { AppDatabaseService } from '../../../database/database.service';

const affiliateSelect = {
  id: true,
  fullName: true,
  affiliateType: true,
  affiliationDate: true,
  status: true,
} satisfies Prisma.AffiliateSelect;

export type Affiliate = Prisma.AffiliateGetPayload<{ select: typeof affiliateSelect }>;

export interface ListAffiliatesOptions {
  limit: number;
  offset: number;
  status?: AffiliateStatus;
  q?: string;
}

export interface AffiliatePage {
  items: Affiliate[];
  total: number;
}

@Injectable()
export class AffiliatesRepository {
  constructor(private readonly appDatabase: AppDatabaseService) {}

  findPage(actorUserId: number, options: ListAffiliatesOptions): Promise<AffiliatePage> {
    const where: Prisma.AffiliateWhereInput = {
      status: options.status,
      fullName:
        options.q === undefined
          ? undefined
          : { contains: options.q, mode: 'insensitive' },
    };

    return this.appDatabase.withActor(actorUserId, async (tx) => {
      const [items, total] = await Promise.all([
        tx.affiliate.findMany({
        select: affiliateSelect,
        where,
        orderBy: { id: 'asc' },
        take: options.limit,
        skip: options.offset,
        }),
        tx.affiliate.count({ where }),
      ]);

      return { items, total };
    });
  }

  findById(actorUserId: number, affiliateId: number): Promise<Affiliate | null> {
    return this.appDatabase.withActor(actorUserId, (tx) =>
      tx.affiliate.findUnique({
        where: { id: affiliateId },
        select: affiliateSelect,
      }),
    );
  }
}
