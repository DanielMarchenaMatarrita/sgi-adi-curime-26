import { Injectable } from '@nestjs/common';
import { ListAffiliatesQueryDto } from '../../dto/list-affiliates-query.dto';
import { AffiliatesRepository } from '../../repositories/affiliates.repository';
import { AffiliateResponse, toResponse } from '../get-affiliate/get-affiliate.service';

export interface ListAffiliatesResponse {
  items: AffiliateResponse[];
  limit: number;
  offset: number;
  total: number;
}

@Injectable()
export class ListAffiliatesService {
  constructor(private readonly affiliatesRepository: AffiliatesRepository) {}

  async execute(
    actorUserId: number,
    query: ListAffiliatesQueryDto,
  ): Promise<ListAffiliatesResponse> {
    const page = await this.affiliatesRepository.findPage(actorUserId, query);
    return {
      items: page.items.map(toResponse),
      limit: query.limit,
      offset: query.offset,
      total: page.total,
    };
  }
}
