import { Prisma, PrismaClient } from '@prisma/client';
import {
  AppDatabaseService,
  AuditLogEntry,
  runWithRlsContext,
} from './database.service';

type RawCall = { strings: readonly string[]; values: readonly unknown[] };

function createTransactionMock(): {
  tx: Prisma.TransactionClient;
  calls: RawCall[];
} {
  const calls: RawCall[] = [];
  const tx = {
    $executeRaw: jest.fn(
      (strings: TemplateStringsArray, ...values: unknown[]): Promise<number> => {
        calls.push({ strings: Array.from(strings), values });
        return Promise.resolve(1);
      },
    ),
  } as unknown as Prisma.TransactionClient;

  return { tx, calls };
}

describe('RLS transaction context', () => {
  it('sets auth role and transaction-local GUC values before work', async () => {
    const { tx, calls } = createTransactionMock();
    const client = {
      $transaction: jest.fn(
        async (work: (transaction: Prisma.TransactionClient) => Promise<unknown>) =>
          work(tx),
      ),
    };
    const work = jest.fn(async () => 'result');

    await expect(
      runWithRlsContext(client as unknown as PrismaClient, 'sgi_auth_runtime', {
        actorUserId: '',
        lookupIdentifier: 'user@example.test',
      }, work),
    ).resolves.toBe('result');

    expect(client.$transaction).toHaveBeenCalledTimes(1);
    expect(work).toHaveBeenCalledWith(tx);
    expect(calls).toEqual([
      { strings: ['SET LOCAL ROLE sgi_auth_runtime'], values: [] },
      {
        strings: ["SELECT set_config('sgi.actor_user_id', ", ', true)'],
        values: [''],
      },
      {
        strings: ["SELECT set_config('sgi.auth_lookup_identifier', ", ', true)'],
        values: ['user@example.test'],
      },
    ]);
  });

  it('uses app role and a parameterized INSERT without RETURNING for audit', async () => {
    const { tx, calls } = createTransactionMock();
    const client = {
      $transaction: jest.fn(
        async (work: (transaction: Prisma.TransactionClient) => Promise<unknown>) =>
          work(tx),
      ),
      $disconnect: jest.fn(),
    };
    const service = new AppDatabaseService(client as unknown as PrismaClient);
    const entry: AuditLogEntry = {
      action: 'CREATE',
      module: 'identity',
      details: { source: 'unit-test' },
    };

    await service.appendAuditLog(17, entry);

    expect(calls[0]).toEqual({ strings: ['SET LOCAL ROLE sgi_app_runtime'], values: [] });
    expect(calls[1].values).toEqual(['17']);
    expect(calls[2].values).toEqual(['']);
    expect(calls[3].strings.join('')).toContain('INSERT INTO public.audit_logs');
    expect(calls[3].strings.join('')).not.toContain('RETURNING');
    expect(calls[3].values).toEqual([
      'CREATE',
      'identity',
      null,
      null,
      '{"source":"unit-test"}',
      null,
      null,
      17,
    ]);
  });

  it('rejects non-positive app actor identifiers before opening a transaction', () => {
    const client = {
      $transaction: jest.fn(),
      $disconnect: jest.fn(),
    };
    const service = new AppDatabaseService(client as unknown as PrismaClient);

    expect(() => service.withActor(0, async () => undefined)).toThrow(
      'actorUserId must be a positive integer',
    );
    expect(client.$transaction).not.toHaveBeenCalled();
  });
});
