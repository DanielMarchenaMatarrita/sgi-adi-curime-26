export interface FlowNode {
  id: string
  label: string
  subtitle: string
  icon: string
}

export interface AuditLogEntry {
  id: string
  timestamp: string
  operation: 'CREATE' | 'UPDATE' | 'REJECT' | 'LOGIN' | 'HEARTBEAT'
  artifact: string
  actor: string
}

export interface ControlStats {
  quorumPercent: number
  quorumPresent: number
  quorumTotal: number
  availableFunds: number
  pendingFunds: number
  executedFunds: number
  dinadecoCompliance: number
  civilParticipation: number
}
