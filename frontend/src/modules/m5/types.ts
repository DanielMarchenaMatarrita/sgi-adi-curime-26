export type TransactionType = 'INGRESO' | 'EGRESO'
export type TransactionStatus = 'CIFRADO' | 'PENDIENTE' | 'ANULADO'

export interface Transaction {
  id: string
  referenceCode: string
  date: string
  concept: string
  origin: string
  amount: number
  type: TransactionType
  auditHash: string
  status: TransactionStatus
}

export interface M5Stats {
  consolidatedBalance: number
  pettyCash: number
  pendingCommitments: number
  activeProjects: number
  monthlyDonations: number
  budgetExecution: number
}
