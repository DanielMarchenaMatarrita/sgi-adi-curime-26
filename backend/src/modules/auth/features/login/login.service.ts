import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as argon2 from 'argon2';
import { AuthRepository } from '../../repositories/auth.repository';
import { LoginDto } from './login.dto';

const ACCESS_TOKEN_TTL_SECONDS = 3600;

export interface LoginResponse {
  accessToken: string;
  tokenType: 'Bearer';
  expiresIn: number;
}

@Injectable()
export class LoginService {
  constructor(
    private readonly authRepository: AuthRepository,
    private readonly jwtService: JwtService,
  ) {}

  async execute(login: LoginDto): Promise<LoginResponse> {
    const user = await this.authRepository.findByEmail(login.email);

    if (
      user === null ||
      user.status !== 'ACTIVE' ||
      user.passwordHash === null ||
      !user.passwordHash.startsWith('$argon2id$')
    ) {
      throw invalidCredentials();
    }

    const passwordMatches = await argon2.verify(user.passwordHash, login.password);

    if (!passwordMatches) {
      throw invalidCredentials();
    }

    const accessToken = await this.jwtService.signAsync(
      { sub: user.id },
      { algorithm: 'HS256', expiresIn: ACCESS_TOKEN_TTL_SECONDS },
    );

    return {
      accessToken,
      tokenType: 'Bearer',
      expiresIn: ACCESS_TOKEN_TTL_SECONDS,
    };
  }
}

function invalidCredentials(): UnauthorizedException {
  return new UnauthorizedException('Invalid credentials');
}
