import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import {
  AuthenticatedRequest,
  JwtAuthGuard,
} from '../../auth/guards/jwt-auth.guard';
import {
  CurrentUserResponse,
  GetCurrentUserService,
} from '../features/get-current-user/get-current-user.service';
import {
  EffectivePermissionsResponse,
  GetEffectivePermissionsService,
} from '../features/get-effective-permissions/get-effective-permissions.service';

@Controller('users')
export class UsersController {
  constructor(
    private readonly getCurrentUserService: GetCurrentUserService,
    private readonly getEffectivePermissionsService: GetEffectivePermissionsService,
  ) {}

  @Get('me')
  @UseGuards(JwtAuthGuard)
  me(@Req() request: AuthenticatedRequest): Promise<CurrentUserResponse> {
    return this.getCurrentUserService.execute(request.user?.sub);
  }

  @Get('me/permissions')
  @UseGuards(JwtAuthGuard)
  permissions(
    @Req() request: AuthenticatedRequest,
  ): Promise<EffectivePermissionsResponse> {
    return this.getEffectivePermissionsService.execute(request.user?.sub);
  }
}
