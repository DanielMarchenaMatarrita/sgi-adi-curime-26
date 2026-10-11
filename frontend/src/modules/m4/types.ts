export type ActaStatus = 'BORRADOR' | 'APROBADA' | 'FIRMANDO'
export type SignatureStatus = 'FIRMADO' | 'PENDIENTE'

export interface Acta {
  id: string
  title: string
  sessionNumber: string
  date: string
  status: ActaStatus
  content: string
  integrityHash: string
  version: number
}

export interface ActaVersion {
  version: number
  timestamp: string
  author: string
  description: string
}

export interface BoardSignature {
  memberName: string
  role: string
  documentNumber: string
  status: SignatureStatus
  signedAt?: string
}

export interface M4Stats {
  treesSaved: number
  totalActas: number
  pendingSignatures: number
}