import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AppDatabaseService } from '../../../database/database.service';
import { REQUIRE_PERMISSIONS_KEY } from '../decorators/require-permissions.decorator';
import { AuthenticatedRequest, JwtAuthGuard } from './jwt-auth.guard';

interface EffectivePermission {
  code: string;
}

@Injectable()
export class PermissionGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly appDatabase: AppDatabaseService,
    private readonly jwtAuthGuard: JwtAuthGuard,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    await this.jwtAuthGuard.canActivate(context);

    const requiredPermissions = this.reflector.getAllAndOverride<string[]>(
      REQUIRE_PERMISSIONS_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (requiredPermissions === undefined) {
      return true;
    }

    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const effectivePermissions = await this.findEffectivePermissions(
      request.user!.sub as number,
    );
    const effectivePermissionCodes = new Set(
      effectivePermissions.map((permission) => permission.code),
    );

    if (!requiredPermissions.every((code) => effectivePermissionCodes.has(code))) {
      throw new ForbiddenException();
    }

    return true;
  }

  private findEffectivePermissions(
    actorUserId: number,
  ): Promise<EffectivePermission[]> {
    return this.appDatabase.withActor(actorUserId, (tx) =>
      tx.$queryRaw<EffectivePermission[]>`
        SELECT DISTINCT p."code"
        FROM public."UserRole" ur
        JOIN public."Role" r ON r."id" = ur."roleId"
        JOIN public."RolePermission" rp ON rp."roleId" = r."id"
        JOIN public."Permission" p ON p."id" = rp."permissionId"
      `,
    );
  }
}
