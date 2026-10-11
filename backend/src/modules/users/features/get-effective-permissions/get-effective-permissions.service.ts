import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersRepository } from '../../repositories/users.repository';

export interface EffectivePermissionsResponse {
  permissions: string[];
}

@Injectable()
export class GetEffectivePermissionsService {
  constructor(private readonly usersRepository: UsersRepository) {}

  async execute(subject: unknown): Promise<EffectivePermissionsResponse> {
    if (!isPositiveInt4(subject)) {
      throw unauthorized();
    }

    const actor = await this.usersRepository.findCurrentById(subject);
    if (actor === null || actor.status !== 'ACTIVE') {
      throw unauthorized();
    }

    const permissions = await this.usersRepository.findEffectivePermissions(subject);
    return { permissions: permissions.map((permission) => permission.code) };
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

function unauthorized(): UnauthorizedException {
  return new UnauthorizedException();
}
