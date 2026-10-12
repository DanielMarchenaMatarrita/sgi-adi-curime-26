import { Inject, Injectable, OnApplicationShutdown } from '@nestjs/common';
import { Prisma, PrismaClient } from '@prisma/client';
import { APP_PRISMA_CLIENT, AUTH_PRISMA_CLIENT } from './database.tokens';

type RuntimeRole = 'sgi_auth_runtime' | 'sgi_app_runtime';

interface AuthContext {
  actorUserId: '';
  lookupIdentifier: string;
}

interface AppContext {
  actorUserId: number;
  lookupIdentifier: '';
}

export interface AuditLogEntry {
  action: string;
  module: string;
  entityType?: string | null;
  entityId?: string | null;
  details?: Prisma.InputJsonValue | null;
  ipAddress?: string | null;
  userAgent?: string | null;
}

export async function runWithRlsContext<T>(
  client: Pick<PrismaClient, '$transaction'>,
  role: RuntimeRole,
  context: AuthContext | AppContext,
  work: (tx: Prisma.TransactionClient) => Promise<T>,
): Promise<T> {
  return client.$transaction(async (tx) => {
    await setLocalRole(tx, role);
    await tx.$executeRaw`SELECT set_config('sgi.actor_user_id', ${String(context.actorUserId)}, true)`;
    await tx.$executeRaw`SELECT set_config('sgi.auth_lookup_identifier', ${context.lookupIdentifier}, true)`;
    return work(tx);
  });
}

async function setLocalRole(
  tx: Prisma.TransactionClient,
  role: RuntimeRole,
): Promise<void> {
  if (role === 'sgi_auth_runtime') {
    await tx.$executeRaw`SET LOCAL ROLE sgi_auth_runtime`;
    return;
  }

  await tx.$executeRaw`SET LOCAL ROLE sgi_app_runtime`;
}

@Injectable()
export class AuthDatabaseService implements OnApplicationShutdown {
  constructor(
    @Inject(AUTH_PRISMA_CLIENT) private readonly client: PrismaClient,
  ) {}

  withLookup<T>(
    lookupIdentifier: string,
    work: (tx: Prisma.TransactionClient) => Promise<T>,
  ): Promise<T> {
    if (lookupIdentifier.trim() === '') {
      throw new Error('lookupIdentifier must be defined');
    }

    return runWithRlsContext(this.client, 'sgi_auth_runtime', {
      actorUserId: '',
      lookupIdentifier,
    }, work);
  }

  async onApplicationShutdown(): Promise<void> {
    await this.client.$disconnect();
  }
}

@Injectable()
export class AppDatabaseService implements OnApplicationShutdown {
  constructor(
    @Inject(APP_PRISMA_CLIENT) private readonly client: PrismaClient,
  ) {}

  withActor<T>(
    actorUserId: number,
    work: (tx: Prisma.TransactionClient) => Promise<T>,
  ): Promise<T> {
    assertPositiveActorId(actorUserId);

    return runWithRlsContext(this.client, 'sgi_app_runtime', {
      actorUserId,
      lookupIdentifier: '',
    }, work);
  }

  async appendAuditLog(actorUserId: number, entry: AuditLogEntry): Promise<void> {
    await this.withActor(actorUserId, async (tx) => {
      const details = entry.details === undefined ? null : JSON.stringify(entry.details);

      await tx.$executeRaw`
        INSERT INTO public."AuditLog" (
          "action", "module", "entityType", "entityId", "details", "ipAddress", "userAgent", "userId"
        ) VALUES (
          ${entry.action}, ${entry.module}, ${entry.entityType ?? null}, ${entry.entityId ?? null},
          ${details}::jsonb, ${entry.ipAddress ?? null}, ${entry.userAgent ?? null}, ${actorUserId}
        )
      `;
    });
  }

  async onApplicationShutdown(): Promise<void> {
    await this.client.$disconnect();
  }
}

function assertPositiveActorId(actorUserId: number): void {
  if (!Number.isSafeInteger(actorUserId) || actorUserId < 1) {
    throw new Error('actorUserId must be a positive integer');
  }
}
