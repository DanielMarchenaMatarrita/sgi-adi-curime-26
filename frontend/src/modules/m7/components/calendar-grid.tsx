import { useState, useMemo } from 'react'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { MOCK_CALENDAR_EVENTS } from '../data/mock-data'

const WEEKDAYS = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']

function getDaysInMonth(year: number, month: number) {
  return new Date(year, month + 1, 0).getDate()
}

function getFirstDayOfMonth(year: number, month: number) {
  const day = new Date(year, month, 1).getDay()
  return day === 0 ? 6 : day - 1
}

export function CalendarGrid() {
  const today = new Date()
  const [currentMonth, setCurrentMonth] = useState(today.getMonth())
  const [currentYear, setCurrentYear] = useState(today.getFullYear())

  const daysInMonth = getDaysInMonth(currentYear, currentMonth)
  const firstDay = getFirstDayOfMonth(currentYear, currentMonth)

  const prevMonth = () => {
    if (currentMonth === 0) {
      setCurrentMonth(11)
      setCurrentYear((y) => y - 1)
    } else {
      setCurrentMonth((m) => m - 1)
    }
  }

  const nextMonth = () => {
    if (currentMonth === 11) {
      setCurrentMonth(0)
      setCurrentYear((y) => y + 1)
    } else {
      setCurrentMonth((m) => m + 1)
    }
  }

  const monthName = new Date(currentYear, currentMonth).toLocaleDateString('es-ES', {
    month: 'long',
    year: 'numeric',
  })

  const cells = useMemo(() => {
    const arr: (number | null)[] = []
    for (let i = 0; i < firstDay; i++) arr.push(null)
    for (let d = 1; d <= daysInMonth; d++) arr.push(d)
    return arr
  }, [firstDay, daysInMonth])

  const isToday = (day: number) =>
    day === today.getDate() &&
    currentMonth === today.getMonth() &&
    currentYear === today.getFullYear()

  const dateKey = (day: number) => {
    const mm = String(currentMonth + 1).padStart(2, '0')
    const dd = String(day).padStart(2, '0')
    return `${currentYear}-${mm}-${dd}`
  }

  return (
    <div className="rounded-xl border border-border bg-card p-4">
      <div className="mb-4 flex items-center justify-between">
        <button onClick={prevMonth} className="rounded-lg p-1.5 hover:bg-muted">
          <ChevronLeft className="h-5 w-5 text-muted-foreground" />
        </button>
        <h3 className="text-sm font-semibold capitalize text-foreground">{monthName}</h3>
        <button onClick={nextMonth} className="rounded-lg p-1.5 hover:bg-muted">
          <ChevronRight className="h-5 w-5 text-muted-foreground" />
        </button>
      </div>

      <div className="mb-1 grid grid-cols-7 gap-1">
        {WEEKDAYS.map((wd) => (
          <div key={wd} className="py-1 text-center text-xs font-medium text-muted-foreground">
            {wd}
          </div>
        ))}
      </div>

      <div className="grid grid-cols-7 gap-1">
        {cells.map((day, i) => {
          if (day === null) return <div key={`e-${i}`} />
          const events = MOCK_CALENDAR_EVENTS[dateKey(day)]
          const hasEvents = events && events.length > 0
          const isSalon = hasEvents && events!.some((e) => e.facility === 'SALON')
          const isCancha = hasEvents && events!.some((e) => e.facility === 'CANCHA')

          return (
            <div
              key={day}
              className={`relative flex flex-col items-center rounded-lg py-1.5 text-sm ${
                isToday(day)
                  ? 'bg-primary font-bold text-primary-foreground'
                  : 'text-foreground hover:bg-muted'
              }`}
            >
              {day}
              {hasEvents && (
                <div className="mt-0.5 flex gap-0.5">
                  {isSalon && (
                    <span className="h-1.5 w-1.5 rounded-full bg-blue-500" />
                  )}
                  {isCancha && (
                    <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
                  )}
                </div>
              )}
            </div>
          )
        })}
      </div>
    </div>
  )
}
