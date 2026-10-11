import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AppDatabaseService } from '../../../database/database.service';
import { PermissionGuard } from './permission.guard';
import { AuthenticatedRequest, JwtAuthGuard } from './jwt-auth.guard';

describe('PermissionGuard', () => {
  const reflector = {
    getAllAndOverride: jest.fn(),
  } as unknown as Reflector;
  const appDatabase = {
    withActor: jest.fn(),
  } as unknown as AppDatabaseService;
  const jwtAuthGuard = {
    canActivate: jest.fn(),
  } as unknown as JwtAuthGuard;
  const guard = new PermissionGuard(reflector, appDatabase, jwtAuthGuard);

  beforeEach(() => {
    jest.clearAllMocks();
    jest.mocked(jwtAuthGuard.canActivate).mockResolvedValue(true);
  });

  it('requires every declared permission', async () => {
    jest.mocked(reflector.getAllAndOverride).mockReturnValue(['users.read', 'users.write']);
    jest.mocked(appDatabase.withActor).mockResolvedValue([
      { code: 'users.read' },
      { code: 'users.write' },
    ]);

    await expect(guard.canActivate(createContext(17))).resolves.toBe(true);
    expect(appDatabase.withActor).toHaveBeenCalledWith(17, expect.any(Function));
  });

  it('returns 403 when an actor lacks any declared permission', async () => {
    jest.mocked(reflector.getAllAndOverride).mockReturnValue(['users.read', 'users.write']);
    jest.mocked(appDatabase.withActor).mockResolvedValue([{ code: 'users.read' }]);

    await expect(guard.canActivate(createContext(17))).rejects.toBeInstanceOf(
      ForbiddenException,
    );
  });

  it('permits authenticated requests when permission metadata is absent', async () => {
    jest.mocked(reflector.getAllAndOverride).mockReturnValue(undefined);

    await expect(guard.canActivate(createContext(17))).resolves.toBe(true);
    expect(appDatabase.withActor).not.toHaveBeenCalled();
  });
});

function createContext(subject: number): ExecutionContext {
  const request = { user: { sub: subject } } as AuthenticatedRequest;
  return {
    getClass: () => class TestController {},
    getHandler: () => () => undefined,
    switchToHttp: () => ({ getRequest: () => request }),
  } as unknown as ExecutionContext;
}
