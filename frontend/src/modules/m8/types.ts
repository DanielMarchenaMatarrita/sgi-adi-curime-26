export type AssetStatus = 'DISPONIBLE' | 'PRESTADO' | 'EN_MANTENIMIENTO' | 'DANADO'
export type LoanStatus = 'ACTIVO' | 'DEVUELTO' | 'VENCIDO'

export interface Asset {
  id: string
  code: string
  name: string
  category: string
  status: AssetStatus
  description: string
}

export interface Loan {
  id: string
  assetCode: string
  assetName: string
  borrower: string
  loanDate: string
  returnDate?: string
  status: LoanStatus
  encryptedId: string
}

export interface M8Stats {
  totalAssets: number
  onLoan: number
  inMaintenance: number
}
