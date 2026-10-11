import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UserStatus } from '@prisma/client';
import { CurrentUser, UsersRepository } from '../../repositories/users.repository';

export interface CurrentUserResponse {
  id: number;
  fullName: string;
  email: string;
  status: UserStatus;
}

@Injectable()
export class GetCurrentUserService {
  constructor(private readonly usersRepository: UsersRepository) {}

  async execute(subject: unknown): Promise<CurrentUserResponse> {
    if (!isPositiveInt4(subject)) {
      throw unauthorized();
    }

    const user = await this.usersRepository.findCurrentById(subject);
    if (user === null || user.status !== 'ACTIVE') {
      throw unauthorized();
    }

    return toResponse(user);
  }
}

function isPositiveInt4(value: unknown): value is number {
  return (
    typeof value === 'number' &&
    Number.isSafeInteger(value) &&
    value >= 1 &&
    value <= 2_147_483_647
  );
}

function toResponse(user: CurrentUser): CurrentUserResponse {
  return {
    id: user.id,
    fullName: user.fullName,
    email: user.email,
    status: user.status,
  };
}

function unauthorized(): UnauthorizedException {
  return new UnauthorizedException();
}
