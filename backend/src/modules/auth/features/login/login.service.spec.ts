jest.mock('argon2', () => ({ verify: jest.fn() }));

import { UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as argon2 from 'argon2';
import { AuthRepository } from '../../repositories/auth.repository';
import { LoginDto } from './login.dto';
import { LoginService } from './login.service';

describe('LoginService', () => {
  const authRepository = {
    findByEmail: jest.fn(),
  } as unknown as AuthRepository;
  const jwtService = {
    signAsync: jest.fn(),
  } as unknown as JwtService;
  const service = new LoginService(authRepository, jwtService);
  const login = LoginDto.parse({ email: 'user@example.test', password: 'password' });
  const passwordHash = '$argon2id$v=19$m=65536,t=3,p=1$c2FsdA$aGFzaA';

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('signs a 3600-second access token for matching active user credentials', async () => {
    jest.mocked(authRepository.findByEmail).mockResolvedValue({
      id: 7,
      passwordHash,
      status: 'ACTIVE',
    });
    jest.mocked(argon2.verify).mockResolvedValue(true);
    jest.mocked(jwtService.signAsync).mockResolvedValue('signed-token');

    await expect(service.execute(login)).resolves.toEqual({
      accessToken: 'signed-token',
      tokenType: 'Bearer',
      expiresIn: 3600,
    });
    expect(authRepository.findByEmail).toHaveBeenCalledWith('user@example.test');
    expect(argon2.verify).toHaveBeenCalledWith(passwordHash, 'password');
    expect(jwtService.signAsync).toHaveBeenCalledWith(
      { sub: 7 },
      { algorithm: 'HS256', expiresIn: 3600 },
    );
  });

  it.each([
    [null],
    [{ id: 7, passwordHash, status: 'INACTIVE' as const }],
    [{ id: 7, passwordHash: null, status: 'ACTIVE' as const }],
    [{ id: 7, passwordHash: '$argon2i$v=19$m=65536,t=3,p=1$c2FsdA$aGFzaA', status: 'ACTIVE' as const }],
  ])('rejects credentials that cannot log in', async (user) => {
    jest.mocked(authRepository.findByEmail).mockResolvedValue(user);

    await expect(service.execute(login)).rejects.toThrow(UnauthorizedException);
    expect(argon2.verify).not.toHaveBeenCalled();
    expect(jwtService.signAsync).not.toHaveBeenCalled();
  });

  it('returns generic unauthorized response when password does not match', async () => {
    jest.mocked(authRepository.findByEmail).mockResolvedValue({
      id: 7,
      passwordHash,
      status: 'ACTIVE',
    });
    jest.mocked(argon2.verify).mockResolvedValue(false);

    await expect(service.execute(login)).rejects.toMatchObject({
      status: 401,
      message: 'Invalid credentials',
    });
    expect(jwtService.signAsync).not.toHaveBeenCalled();
  });
});
