import { Injectable } from '@nestjs/common';
import { UserStatus } from '@prisma/client';
import { AuthDatabaseService } from '../../../database/database.service';

export interface LoginUser {
  id: number;
  passwordHash: string | null;
  status: UserStatus;
}

@Injectable()
export class AuthRepository {
  constructor(private readonly authDatabase: AuthDatabaseService) {}

  findByEmail(email: string): Promise<LoginUser | null> {
    return this.authDatabase.withLookup(email, (tx) =>
      tx.user.findUnique({
        where: { email },
        select: { id: true, passwordHash: true, status: true },
      }),
    );
  }
}
