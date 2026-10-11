import { cn } from '@/shared/lib/utils'
import { ShieldCheck, Copy } from 'lucide-react'
import { truncateUuid } from '@/shared/lib/utils'

interface CryptoBadgeProps {
  hash: string
  label?: string
  truncated?: boolean
  showCopy?: boolean
  className?: string
}

function CryptoBadge({
  hash,
  label = 'UUID',
  truncated = true,
  showCopy = false,
  className,
}: CryptoBadgeProps) {
  const displayHash = truncated ? truncateUuid(hash) : hash

  return (
    <span
      className={cn(
        'inline-flex items-center gap-1 rounded border border-primary/10 bg-primary/5 px-1.5 py-0.5 font-mono text-[10px] uppercase text-primary',
        className
      )}
    >
      <ShieldCheck className="h-3 w-3 text-primary/60" />
      {label}: {displayHash}
      {showCopy && (
        <button
          onClick={() => navigator.clipboard.writeText(hash)}
          className="ml-0.5 text-primary/40 hover:text-primary transition-colors"
        >
          <Copy className="h-2.5 w-2.5" />
        </button>
      )}
    </span>
  )
}

export { CryptoBadge }
export type { CryptoBadgeProps }
