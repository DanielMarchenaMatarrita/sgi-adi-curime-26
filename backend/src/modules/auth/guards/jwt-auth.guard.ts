import {
    CanActivate,
    ExecutionContext,
    Inject,
    Injectable,
    UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';

export const JWT_AUTH_GUARD_OPTIONS = Symbol('JWT_AUTH_GUARD_OPTIONS');

export interface JwtAuthGuardOptions {
    issuer: string;
    audience: string;
}

export interface JwtClaims {
    sub: unknown;
    exp?: unknown;
    [claim: string]: unknown;
}

export type AuthenticatedRequest = Request & { user?: JwtClaims };

@Injectable()
export class JwtAuthGuard implements CanActivate {
    constructor(
        private readonly jwtService: JwtService,
        @Inject(JWT_AUTH_GUARD_OPTIONS)
        private readonly options: JwtAuthGuardOptions,
    ) { }

    async canActivate(context: ExecutionContext): Promise<boolean> {
        const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
        const authorization = request.headers.authorization;

        if (typeof authorization !== 'string') {
            throw new UnauthorizedException();
        }

        const match = /^Bearer\s+([^\s]+)$/i.exec(authorization);
        if (match === null) {
            throw new UnauthorizedException();
        }

        let claims: JwtClaims;
        try {
            claims = await this.jwtService.verifyAsync<JwtClaims>(match[1], {
                algorithms: ['HS256'],
                issuer: this.options.issuer,
                audience: this.options.audience,
            });
        } catch {
            throw new UnauthorizedException();
        }

        if (!isPositiveInteger(claims.sub) || !isValidExpiration(claims.exp)) {
            throw new UnauthorizedException();
        }

        request.user = claims;
        return true;
    }
}

function isPositiveInteger(value: unknown): value is number {
    return typeof value === 'number' && Number.isSafeInteger(value) && value > 0;
}

function isValidExpiration(value: unknown): value is number {
    return (
        typeof value === 'number' &&
        Number.isSafeInteger(value) &&
        value > Math.floor(Date.now() / 1000)
    );
}