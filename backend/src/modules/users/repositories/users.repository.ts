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
        FROM public.user_roles ur
        JOIN public.roles r ON r."id" = ur.role_id
        JOIN public.role_permissions rp ON rp.role_id = r."id"
        JOIN public.permissions p ON p."id" = rp.permission_id
        ORDER BY p."code"
      `,
    );
  }
}
