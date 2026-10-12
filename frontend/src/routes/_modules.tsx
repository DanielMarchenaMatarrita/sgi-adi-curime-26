import { createFileRoute } from '@tanstack/react-router'
import { AppLayout } from '@/shared/components/layout/app-layout'

export const Route = createFileRoute('/_modules')({
  component: AppLayout,
})
