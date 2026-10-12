import { Controller, Get, Param, Query, Req, UseGuards } from '@nestjs/common';
import {
  AuthenticatedRequest,
} from '../../auth/guards/jwt-auth.guard';
import { PermissionGuard } from '../../auth/guards/permission.guard';
import { RequirePermissions } from '../../auth/decorators/require-permissions.decorator';
import { AffiliateIdParamDto } from '../dto/affiliate-id-param.dto';
import { ListAffiliatesQueryDto } from '../dto/list-affiliates-query.dto';
import {
  AffiliateResponse,
  GetAffiliateService,
} from '../features/get-affiliate/get-affiliate.service';
import {
  ListAffiliatesResponse,
  ListAffiliatesService,
} from '../features/list-affiliates/list-affiliates.service';

@Controller('affiliates')
@UseGuards(PermissionGuard)
@RequirePermissions('affiliates.read')
export class AffiliatesController {
  constructor(
    private readonly listAffiliatesService: ListAffiliatesService,
    private readonly getAffiliateService: GetAffiliateService,
  ) {}

  @Get()
  list(
    @Req() request: AuthenticatedRequest,
    @Query() query: Record<string, unknown>,
  ): Promise<ListAffiliatesResponse> {
    return this.listAffiliatesService.execute(
      request.user!.sub as number,
      ListAffiliatesQueryDto.parse(query),
    );
  }

  @Get(':affiliateId')
  getById(
    @Req() request: AuthenticatedRequest,
    @Param() params: Record<string, unknown>,
  ): Promise<AffiliateResponse> {
    return this.getAffiliateService.execute(
      request.user!.sub as number,
      AffiliateIdParamDto.parse(params).affiliateId,
    );
  }
}
