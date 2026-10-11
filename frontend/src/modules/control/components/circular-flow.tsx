import { FileCheck, Zap, CreditCard, ArrowRight } from 'lucide-react'
import type { FlowNode } from '../types'

const iconMap: Record<string, React.ReactNode> = {
  FileCheck: <FileCheck className="h-6 w-6 text-primary" />,
  Zap: <Zap className="h-6 w-6 text-amber-500" />,
  CreditCard: <CreditCard className="h-6 w-6 text-emerald-600" />,
}

interface CircularFlowProps {
  nodes: FlowNode[]
}

function CircularFlow({ nodes }: CircularFlowProps) {
  return (
    <div className="rounded-xl border border-outline-variant bg-surface p-6">
      <h3 className="mb-1 font-title-md text-title-md text-on-surface">
        Flujo Circular de Gobernanza
      </h3>
      <p className="mb-4 text-xs text-on-surface-variant">
        Proceso automatizado de validación y ejecución
      </p>

      <div className="flex items-center justify-between gap-2">
        {nodes.map((node, index) => (
          <div key={node.id} className="flex items-center gap-2">
            <div className="flex flex-col items-center gap-2 rounded-lg border border-outline-variant bg-surface-container-low p-4 text-center min-w-[140px]">
              <div className="flex h-12 w-12 items-center justify-center rounded-full bg-surface-container">
                {iconMap[node.icon]}
              </div>
              <div>
                <p className="text-sm font-bold text-on-surface">{node.label}</p>
                <p className="mt-0.5 text-xs text-on-surface-variant">{node.subtitle}</p>
              </div>
            </div>
            {index < nodes.length - 1 && (
              <ArrowRight className="h-5 w-5 flex-shrink-0 text-primary" />
            )}
          </div>
        ))}
      </div>
    </div>
  )
}

export { CircularFlow }
