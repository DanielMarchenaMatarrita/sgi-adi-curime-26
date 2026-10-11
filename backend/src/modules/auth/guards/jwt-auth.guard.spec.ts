import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import {
    AuthenticatedRequest,
    JwtAuthGuard,
} from './jwt-auth.guard';

describe('JwtAuthGuard', () => {
    const jwtService = {
        verifyAsync: jest.fn(),
    } as unknown as JwtService;
    const guard = new JwtAuthGuard(jwtService, {
        issuer: 'sgi-curime-test',
        audience: 'sgi-curime-test-api',
    });

    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('verifies a bearer token and stores validated claims on the request', async () => {
        const claims = {
            sub: 17,
            exp: Math.floor(Date.now() / 1000) + 60,
            iat: Math.floor(Date.now() / 1000),
        };
        jest.mocked(jwtService.verifyAsync).mockResolvedValue(claims);
        const request = createRequest('Bearer signed-token');

        await expect(guard.canActivate(createContext(request))).resolves.toBe(true);

        expect(jwtService.verifyAsync).toHaveBeenCalledWith('signed-token', {
            algorithms: ['HS256'],
            issuer: 'sgi-curime-test',
            audience: 'sgi-curime-test-api',
        });
        expect(request.user).toEqual(claims);
    });

    it.each([undefined, '', 'Basic credentials', 'Bearer'])('rejects missing or malformed authorization: %s', async (authorization) => {
        const request = createRequest(authorization);

        await expect(guard.canActivate(createContext(request))).rejects.toBeInstanceOf(
            UnauthorizedException,
        );
        expect(jwtService.verifyAsync).not.toHaveBeenCalled();
    });

    it('rejects tokens that fail cryptographic or issuer validation', async () => {
        jest.mocked(jwtService.verifyAsync).mockRejectedValue(new Error('invalid token'));

        await expect(
            guard.canActivate(createContext(createRequest('Bearer invalid-token'))),
        ).rejects.toMatchObject({ status: 401 });
    });

    it.each([
        { sub: 0, exp: 60 },
        { sub: '17', exp: 60 },
        { sub: 17, exp: undefined },
        { sub: 17, exp: Math.floor(Date.now() / 1000) - 1 },
    ])('rejects claims with invalid sub or expiration: %j', async (claims) => {
        jest.mocked(jwtService.verifyAsync).mockResolvedValue(claims);

        await expect(
            guard.canActivate(createContext(createRequest('Bearer signed-token'))),
        ).rejects.toBeInstanceOf(UnauthorizedException);
    });
});

function createRequest(authorization: string | undefined): AuthenticatedRequest {
    return {
        headers: authorization === undefined ? {} : { authorization },
    } as AuthenticatedRequest;
}

function createContext(request: AuthenticatedRequest): ExecutionContext {
    return {
        switchToHttp: () => ({ getRequest: () => request }),
    } as unknown as ExecutionContext;
}