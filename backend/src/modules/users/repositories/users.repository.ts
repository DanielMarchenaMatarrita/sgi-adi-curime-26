import { Injectable } from '@nestjs/common';
import { UserStatus } from '@prisma/client';
import { AppDatabaseService } from '../../../database/database.service';

export interface CurrentUser {
  id: number;
  fullName: string;
  email: string;
  status: UserStatus;
}

export interface EffectivePermission {
  code: string;
}

@Injectable()
export class UsersRepository {
  constructor(private readonly appDatabase: AppDatabaseService) {}

  findCurrentById(actorUserId: number): Promise<CurrentUser | null> {
    return this.appDatabase.withActor(actorUserId, (tx) =>
      tx.user.findUnique({
        where: { id: actorUserId },
        select: {
          id: true,
          fullName: true,
          email: true,
          status: true,
        },
      }),
    );
  }

  findEffectivePermissions(actorUserId: number): Promise<EffectivePermission[]> {
    return this.appDatabase.withActor(actorUserId, (tx) =>
      tx.$queryRaw<EffectivePermission[]>`
        SELECT DISTINCT p."code"
        FROM public."UserRole" ur
        JOIN public."Role" r ON r."id" = ur."roleId"
        JOIN public."RolePermission" rp ON rp."roleId" = r."id"
        JOIN public."Permission" p ON p."id" = rp."permissionId"
        ORDER BY p."code"
      `,
    );
  }
}
