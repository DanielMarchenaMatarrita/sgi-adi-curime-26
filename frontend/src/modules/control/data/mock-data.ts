import type { FlowNode, AuditLogEntry, ControlStats } from '../types'

export const MOCK_FLOW_NODES: FlowNode[] = [
  {
    id: 'step-1',
    label: 'Acta Aprobada',
    subtitle: 'Asamblea validó el acta digital con quórum',
    icon: 'FileCheck',
  },
  {
    id: 'step-2',
    label: 'Inyección Automática',
    subtitle: 'Smart contract ejecuta la transferencia',
    icon: 'Zap',
  },
  {
    id: 'step-3',
    label: 'Orden de Pago',
    subtitle: 'Dispósito bancario registrado on-chain',
    icon: 'CreditCard',
  },
]

export const MOCK_AUDIT_LOG: AuditLogEntry[] = [
  {
    id: 'log-001',
    timestamp: '2026-06-20T14:32:01Z',
    operation: 'CREATE',
    artifact: 'Acta #2026-047',
    actor: 'María Elena Vargas',
  },
  {
    id: 'log-002',
    timestamp: '2026-06-20T14:35:12Z',
    operation: 'LOGIN',
    artifact: 'Sesión #9A3F',
    actor: 'Carlos Mendoza',
  },
  {
    id: 'log-003',
    timestamp: '2026-06-20T14:38:44Z',
    operation: 'UPDATE',
    artifact: 'Orden Pago #1203',
    actor: 'Sistema Automático',
  },
  {
    id: 'log-004',
    timestamp: '2026-06-20T14:41:07Z',
    operation: 'HEARTBEAT',
    artifact: 'Nodo Validador #3',
    actor: 'Infraestructura',
  },
  {
    id: 'log-005',
    timestamp: '2026-06-20T14:43:29Z',
    operation: 'REJECT',
    artifact: 'Acta #2026-048',
    actor: 'Tribunal Electoral',
  },
  {
    id: 'log-006',
    timestamp: '2026-06-20T14:45:51Z',
    operation: 'CREATE',
    artifact: 'Dispositivo DINADECO',
    actor: 'Ana Lucía Rojas',
  },
  {
    id: 'log-007',
    timestamp: '2026-06-20T14:48:03Z',
    operation: 'UPDATE',
    artifact: 'Padrón Electoral',
    actor: 'Comisión Cívica',
  },
  {
    id: 'log-008',
    timestamp: '2026-06-20T14:50:16Z',
    operation: 'LOGIN',
    artifact: 'Sesión #B7D2',
    actor: 'Roberto Jiménez',
  },
]

export const MOCK_CONTROL_STATS: ControlStats = {
  quorumPercent: 78,
  quorumPresent: 156,
  quorumTotal: 200,
  availableFunds: 12500000,
  pendingFunds: 3200000,
  executedFunds: 8750000,
  dinadecoCompliance: 94,
  civilParticipation: 87,
}
