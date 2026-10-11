import { BadRequestException } from '@nestjs/common';

export class LoginDto {
  private constructor(
    readonly email: string,
    readonly password: string,
  ) {}

  static parse(body: unknown): LoginDto {
    if (
      typeof body !== 'object' ||
      body === null ||
      !('email' in body) ||
      !('password' in body) ||
      typeof body.email !== 'string' ||
      typeof body.password !== 'string' ||
      body.email === '' ||
      body.password === ''
    ) {
      throw new BadRequestException('Invalid login request');
    }

    return new LoginDto(body.email, body.password);
  }
}
