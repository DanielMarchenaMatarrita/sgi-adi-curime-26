import { Prisma, PrismaClient } from '@prisma/client';
import {
    AppDatabaseService,
    AuthDatabaseService,
} from '../src/database/database.service';

type UserRow = { id: number; email: string };
type SessionState = {
    backend_pid: number;
    current_user: string;
    actor_user_id: string | null;
    lookup_identifier: string | null;
};

const authDatabaseUrl = process.env.AUTH_DATABASE_URL;
const appDatabaseUrl = process.env.APP_DATABASE_URL;

if (!authDatabaseUrl || !appDatabaseUrl) {
    throw new Error('AUTH_DATABASE_URL and APP_DATABASE_URL are required');
}

function withConnectionLimit(databaseUrl: string, limit: number): string {
    const url = new URL(databaseUrl);
    url.searchParams.set('connection_limit', String(limit));
    return url.toString();
}

function readSessionState(client: PrismaClient): Promise<SessionState[]> {
    return client.$transaction(
        (tx) => tx.$queryRaw<SessionState[]>`
            SELECT
                pg_backend_pid() AS backend_pid,
                current_user,
                current_setting('sgi.actor_user_id', true) AS actor_user_id,
                current_setting('sgi.auth_lookup_identifier', true) AS lookup_identifier
        `,
    );
}

function describeError(error: unknown): string {
    if (error instanceof Error) {
        return `${error.name}: ${error.message}`;
    }

    return String(error);
}

function permissionDeniedEvidence(error: unknown): string[] {
    const evidence: string[] = [];
    const queue: Array<{ value: unknown; path: string }> = [{ value: error, path: 'error' }];
    const visited = new Set<object>();

    while (queue.length > 0) {
        const current = queue.shift();
        if (!current || typeof current.value !== 'object' || current.value === null) {
            continue;
        }

        if (visited.has(current.value)) {
            continue;
        }
        visited.add(current.value);

        const record = current.value as Record<string, unknown>;
        for (const key of ['code', 'sqlState', 'sqlstate']) {
            if (record[key] === '42501') {
                evidence.push(`${current.path}.${key}=42501`);
            }
        }

        // PostgreSQL errors surface through Prisma raw queries as P2010 with meta.code.
        if (record.meta && typeof record.meta === 'object') {
            queue.push({ value: record.meta, path: `${current.path}.meta` });
        }
        if (record.cause && typeof record.cause === 'object') {
            queue.push({ value: record.cause, path: `${current.path}.cause` });
        }
    }

    return evidence;
}

function connectionOrInitializationEvidence(error: unknown): string[] {
    const evidence: string[] = [];
    const queue: Array<{ value: unknown; path: string }> = [{ value: error, path: 'error' }];
    const visited = new Set<object>();

    while (queue.length > 0) {
        const current = queue.shift();
        if (!current || typeof current.value !== 'object' || current.value === null) {
            continue;
        }

        if (visited.has(current.value)) {
            continue;
        }
        visited.add(current.value);

        const record = current.value as Record<string, unknown>;
        if (current.value instanceof Prisma.PrismaClientInitializationError) {
            evidence.push(`${current.path} is PrismaClientInitializationError`);
        }
        if (['P1001', 'P1002', 'P1008', 'P1017'].includes(String(record.code))) {
            evidence.push(`${current.path}.code=${String(record.code)}`);
        }
        if (record.cause && typeof record.cause === 'object') {
            queue.push({ value: record.cause, path: `${current.path}.cause` });
        }
    }

    return evidence;
}

function assertPermissionDenied(error: unknown): void {
    const diagnostic = describeError(error);
    const connectionEvidence = connectionOrInitializationEvidence(error);
    if (connectionEvidence.length > 0) {
        throw new Error(
            `Expected PostgreSQL permission denial (SQLSTATE 42501), received connection/initialization failure (${connectionEvidence.join(', ')}): ${diagnostic}`,
        );
    }

    const evidence = permissionDeniedEvidence(error);
    if (evidence.length === 0) {
        throw new Error(
            `Expected PostgreSQL permission denial (SQLSTATE 42501); no 42501 evidence found in direct error, Prisma meta, or cause. Received: ${diagnostic}`,
        );
    }
}

async function expectPermissionDenied(operation: () => Promise<unknown>): Promise<void> {
    try {
        await operation();
    } catch (error) {
        assertPermissionDenied(error);
        return;
    }

    throw new Error('Expected PostgreSQL permission denial (SQLSTATE 42501), but operation succeeded');
}

function expectCleanReusedSession(
    state: SessionState,
    expectedBackendPid: number,
    validatorRole: 'sgi_auth_validator' | 'sgi_app_validator',
): void {
    expect(state).toMatchObject({
        backend_pid: expectedBackendPid,
        current_user: validatorRole,
        actor_user_id: '',
        lookup_identifier: '',
    });
}

describe('disposable Prisma/RLS integration', () => {
    let authClient: PrismaClient;
    let appClient: PrismaClient;
    let concurrentAppClient: PrismaClient;
    let authDatabase: AuthDatabaseService | undefined;
    let appDatabase: AppDatabaseService | undefined;
    let concurrentAppDatabase: AppDatabaseService | undefined;

    beforeAll(() => {
        authClient = new PrismaClient({
            datasources: { db: { url: withConnectionLimit(authDatabaseUrl, 1) } },
        });
        appClient = new PrismaClient({
            datasources: { db: { url: withConnectionLimit(appDatabaseUrl, 1) } },
        });
        concurrentAppClient = new PrismaClient({
            datasources: { db: { url: withConnectionLimit(appDatabaseUrl, 2) } },
        });
        authDatabase = new AuthDatabaseService(authClient);
        appDatabase = new AppDatabaseService(appClient);
        concurrentAppDatabase = new AppDatabaseService(concurrentAppClient);
    });

    afterAll(async () => {
        await Promise.all(
            [authDatabase, appDatabase, concurrentAppDatabase]
                .filter((database): database is AuthDatabaseService | AppDatabaseService => database !== undefined)
                .map((database) => database.onApplicationShutdown()),
        );
    });

    it('allows scoped auth lookup and denies unauthorized auth access', async () => {
        const before = await readSessionState(authClient);
        expect(before[0]).toMatchObject({
            current_user: 'sgi_auth_validator',
            actor_user_id: null,
            lookup_identifier: null,
        });

        const context = await authDatabase!.withLookup(
            'ana@example.test',
            (tx) => tx.$queryRaw<SessionState[]>`
                SELECT
                    pg_backend_pid() AS backend_pid,
                    current_user,
                    current_setting('sgi.actor_user_id', true) AS actor_user_id,
                    current_setting('sgi.auth_lookup_identifier', true) AS lookup_identifier
            `,
        );
        expect(context[0]).toMatchObject({
            current_user: 'sgi_auth_runtime',
            actor_user_id: '',
            lookup_identifier: 'ana@example.test',
        });
        expect(context[0].backend_pid).toBe(before[0].backend_pid);

        const rows = await authDatabase!.withLookup(
            'ana@example.test',
            (tx) => tx.$queryRaw<UserRow[]>`SELECT "id", "email" FROM public.users`,
        );
        expect(rows).toEqual([{ id: 1, email: 'ana@example.test' }]);

        expectCleanReusedSession((await readSessionState(authClient))[0], before[0].backend_pid, 'sgi_auth_validator');

        await expectPermissionDenied(() =>
            authDatabase!.withLookup(
                'ana@example.test',
                (tx) => tx.$queryRaw`SELECT "full_name" FROM public.users`,
            ),
        );

        const after = await readSessionState(authClient);
        expectCleanReusedSession(after[0], before[0].backend_pid, 'sgi_auth_validator');

        await expectPermissionDenied(() =>
            authDatabase!.withLookup(
                'ana@example.test',
                (tx) => tx.$executeRaw`INSERT INTO public.audit_logs (action, module, user_id) VALUES ('DENIED', 'integration', 1)`,
            ),
        );

        expectCleanReusedSession(
            (await readSessionState(authClient))[0],
            before[0].backend_pid,
            'sgi_auth_validator',
        );
    });

    it('isolates the app role and permits only actor-matching audit writes', async () => {
        const before = await readSessionState(appClient);
        expect(before[0]).toMatchObject({
            current_user: 'sgi_app_validator',
            actor_user_id: null,
            lookup_identifier: null,
        });

        const context = await appDatabase!.withActor(
            1,
            (tx) => tx.$queryRaw<SessionState[]>`
                SELECT
                    pg_backend_pid() AS backend_pid,
                    current_user,
                    current_setting('sgi.actor_user_id', true) AS actor_user_id,
                    current_setting('sgi.auth_lookup_identifier', true) AS lookup_identifier
            `,
        );
        expect(context[0]).toMatchObject({
            current_user: 'sgi_app_runtime',
            actor_user_id: '1',
            lookup_identifier: '',
        });
        expect(context[0].backend_pid).toBe(before[0].backend_pid);

        await expectPermissionDenied(() =>
            appDatabase!.withActor(
                1,
                (tx) => tx.$queryRaw`SELECT "id" FROM public.users`,
            ),
        );

        await expectPermissionDenied(() =>
            appDatabase!.withActor(
                1,
                (tx) => tx.$executeRaw`INSERT INTO public.audit_logs (action, module, user_id) VALUES ('DENIED', 'integration', 2)`,
            ),
        );

        await appDatabase!.appendAuditLog(1, {
            action: 'BE02C_B2_COMMIT',
            module: 'be-02c-b2',
            entityId: 'committed-marker',
        });

        const after = await readSessionState(appClient);
        expectCleanReusedSession(after[0], before[0].backend_pid, 'sgi_app_validator');
    });

    it('rolls back failed work and reuses a clean transaction context', async () => {
        const before = await readSessionState(appClient);

        await expect(
            appDatabase!.withActor(1, async (tx) => {
                await tx.$executeRaw`
                    INSERT INTO public.audit_logs (action, module, entity_id, user_id)
                    VALUES ('BE02C_B2_ROLLBACK', 'be-02c-b2', 'rollback-marker', 1)
                `;
                throw new Error('rollback sentinel');
            }),
        ).rejects.toThrow('rollback sentinel');

        const after = await readSessionState(appClient);
        expectCleanReusedSession(after[0], before[0].backend_pid, 'sgi_app_validator');
    });

    it('keeps concurrent actor contexts isolated on reused pools', async () => {
        const contexts = await Promise.all(
            [1, 2].map((actorUserId) =>
                concurrentAppDatabase!.withActor(actorUserId, async (tx) => {
                    const state = await tx.$queryRaw<SessionState[]>`
                        SELECT
                            pg_backend_pid() AS backend_pid,
                            current_user,
                            current_setting('sgi.actor_user_id', true) AS actor_user_id,
                            current_setting('sgi.auth_lookup_identifier', true) AS lookup_identifier
                    `;
                    await tx.$queryRaw`SELECT 1 FROM pg_sleep(0.2)`;
                    await tx.$executeRaw`
                        INSERT INTO public.audit_logs (action, module, entity_id, user_id)
                        VALUES ('BE02C_B2_CONCURRENT', 'be-02c-b2', ${`concurrent-actor-${actorUserId}`}, ${actorUserId})
                    `;
                    return state[0];
                }),
            ),
        );

        expect(contexts).toHaveLength(2);
        expect(contexts.map((context) => context.current_user)).toEqual([
            'sgi_app_runtime',
            'sgi_app_runtime',
        ]);
        expect(contexts.map((context) => context.actor_user_id)).toEqual(['1', '2']);
        expect(contexts.map((context) => context.lookup_identifier)).toEqual(['', '']);
        expect(new Set(contexts.map((context) => context.backend_pid)).size).toBe(2);
    });
});
