import { BadRequestException } from '@nestjs/common';
import { AuthController } from './auth.controller';
import { LoginService } from '../features/login/login.service';

describe('AuthController', () => {
  const loginService = {
    execute: jest.fn(),
  } as unknown as LoginService;
  const controller = new AuthController(loginService);

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('passes an exact email and password to login service', async () => {
    jest.mocked(loginService.execute).mockResolvedValue({
      accessToken: 'token',
      tokenType: 'Bearer',
      expiresIn: 3600,
    });

    await expect(
      controller.login({ email: 'User@Example.test', password: 'password' }),
    ).resolves.toEqual({
      accessToken: 'token',
      tokenType: 'Bearer',
      expiresIn: 3600,
    });
    expect(loginService.execute).toHaveBeenCalledWith({
      email: 'User@Example.test',
      password: 'password',
    });
  });

  it('rejects malformed requests', () => {
    expect(() => controller.login({ email: 'user@example.test' })).toThrow(
      BadRequestException,
    );
  });
});
