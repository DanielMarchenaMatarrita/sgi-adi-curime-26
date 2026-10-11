import { MapPin, TrendingUp } from 'lucide-react'
import { MOCK_REGIONAL_COVERAGE } from '../data/mock-data'

function RegionalCoverage() {
  const total = MOCK_REGIONAL_COVERAGE.reduce((sum, d) => sum + d.population, 0)

  return (
    <div className="rounded-xl border border-outline-variant/30 bg-surface-container-lowest overflow-hidden">
      <div className="flex items-center justify-between border-b border-outline-variant/20 px-5 py-3.5">
        <div className="flex items-center gap-2.5">
          <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-primary/8">
            <MapPin className="h-3.5 w-3.5 text-primary" />
          </div>
          <h3 className="text-sm font-bold text-on-surface">Distribución Territorial</h3>
        </div>
        <div className="flex items-center gap-1.5 text-xs font-semibold text-success">
          <TrendingUp className="h-3 w-3" />
          98.4% cobertura
        </div>
      </div>

      <div className="p-5">
        {/* Map placeholder */}
        <div className="relative flex h-44 items-center justify-center overflow-hidden rounded-xl bg-gradient-to-br from-primary/5 via-surface-container-low to-primary/3 border border-outline-variant/20">
          {/* Dot pattern */}
          <div
            className="absolute inset-0 opacity-[0.07]"
            style={{
              backgroundImage: 'radial-gradient(circle, #0a7c57 1px, transparent 1px)',
              backgroundSize: '20px 20px',
            }}
          />

          {/* Decorative rings */}
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="h-32 w-32 rounded-full border border-primary/10" />
            <div className="absolute h-48 w-48 rounded-full border border-primary/5" />
          </div>

          {/* Center pin */}
          <div className="relative z-10 flex flex-col items-center gap-1.5">
            <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-gradient-primary shadow-lg shadow-primary/20">
              <MapPin className="h-7 w-7 text-white" fill="currentColor" />
            </div>
            <p className="text-sm font-bold text-on-surface">Curime, Guanacaste</p>
            <p className="text-xs font-medium text-on-surface-variant">
              {total} miembros registrados
            </p>
          </div>

          {/* Floating stats */}
          <div className="absolute left-3 top-3 rounded-lg border border-outline-variant/30 bg-surface-container-lowest/90 backdrop-blur-sm px-3 py-2 shadow-md">
            <p className="text-[10px] font-bold uppercase tracking-wider text-on-surface-variant/60">San José</p>
            <p className="text-sm font-bold text-primary">122</p>
          </div>

          <div className="absolute right-3 bottom-3 rounded-lg border border-outline-variant/30 bg-surface-container-lowest/90 backdrop-blur-sm px-3 py-2 shadow-md">
            <p className="text-[10px] font-bold uppercase tracking-wider text-on-surface-variant/60">Central</p>
            <p className="text-sm font-bold text-primary">145</p>
          </div>
        </div>

        {/* District breakdown */}
        <div className="mt-4 grid grid-cols-3 gap-3">
          {MOCK_REGIONAL_COVERAGE.map((district) => {
            const percentage = (district.population / total) * 100
            return (
              <div
                key={district.district}
                className="rounded-xl border border-outline-variant/20 bg-surface-container-low p-3 text-center transition-all hover:border-primary/20 hover:shadow-sm"
              >
                <p className="text-[10px] font-bold uppercase tracking-wider text-on-surface-variant/60 mb-1">
                  {district.district}
                </p>
                <p className="text-xl font-bold text-primary">
                  {district.population}
                </p>
                <div className="mt-2 h-1.5 w-full overflow-hidden rounded-full bg-outline-variant/20">
                  <div
                    className="h-full rounded-full bg-gradient-primary transition-all duration-500"
                    style={{ width: `${percentage}%` }}
                  />
                </div>
                <p className="mt-1 text-[10px] font-semibold text-on-surface-variant">
                  {district.percentage}%
                </p>
              </div>
            )
          })}
        </div>
      </div>
    </div>
  )
}

export { RegionalCoverage }
