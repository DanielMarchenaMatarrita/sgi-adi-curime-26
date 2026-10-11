import { useEffect, useState, type FormEvent } from 'react'
import { useNavigate, createFileRoute } from '@tanstack/react-router'
import { LockKeyhole, Mail, Trees } from 'lucide-react'
import { Button } from '@/shared/components/ui/button'
import { Input } from '@/shared/components/ui/input'
import { useAuth } from '@/shared/context/auth-context'
import { APP_NAME } from '@/app/config/constants'

function LoginPage() {
    const navigate = useNavigate()
    const { status, error, login, retrySessionRestore } = useAuth()
    const [email, setEmail] = useState('')
    const [password, setPassword] = useState('')
    const [submitted, setSubmitted] = useState(false)

    useEffect(() => {
        if (status === 'authenticated') {
            void navigate({ to: '/' })
        }
    }, [navigate, status])

    async function handleSubmit(event: FormEvent<HTMLFormElement>) {
        event.preventDefault()
        setSubmitted(true)
        const authenticated = await login(email.trim(), password)
        if (authenticated) {
            void navigate({ to: '/' })
        }
    }

    const isSubmitting = status === 'authenticating'

    return (
        <main className="min-h-screen bg-surface px-4 py-10 text-on-surface sm:px-6">
            <div className="mx-auto flex min-h-[calc(100vh-5rem)] max-w-5xl items-center justify-center">
                <section className="grid w-full overflow-hidden rounded-2xl border border-outline-variant/60 bg-surface-container-lowest shadow-xl md:grid-cols-[1.05fr_0.95fr]">
                    <div className="hidden min-h-[520px] flex-col justify-between bg-gradient-primary p-10 text-white md:flex">
                        <div className="flex items-center gap-3">
                            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white/15">
                                <Trees className="h-5 w-5" />
                            </div>
                            <span className="font-display text-2xl italic">{APP_NAME}</span>
                        </div>
                        <div>
                            <p className="mb-3 text-sm font-semibold uppercase tracking-[0.2em] text-white/70">
                                Acceso institucional
                            </p>
                            <h1 className="max-w-md font-display text-5xl leading-[0.95]">
                                Tu comunidad, en buenas manos.
                            </h1>
                            <p className="mt-5 max-w-sm text-sm leading-6 text-white/75">
                                Ingresa para continuar en el ecosistema digital de tu asociación.
                            </p>
                        </div>
                        <p className="text-xs text-white/60">Sesión segura con acceso temporal.</p>
                    </div>

                    <div className="flex min-h-[520px] items-center p-6 sm:p-10">
                        <div className="mx-auto w-full max-w-sm">
                            <div className="mb-8 md:hidden">
                                <div className="mb-5 flex items-center gap-3 text-primary">
                                    <Trees className="h-6 w-6" />
                                    <span className="font-display text-2xl italic">{APP_NAME}</span>
                                </div>
                            </div>
                            <div className="mb-8">
                                <p className="mb-2 text-xs font-bold uppercase tracking-[0.18em] text-primary">
                                    Bienvenido
                                </p>
                                <h2 className="text-3xl font-bold tracking-tight">Inicia sesión</h2>
                                <p className="mt-2 text-sm text-on-surface-variant">
                                    Usa tus credenciales institucionales para continuar.
                                </p>
                            </div>

                            <form className="space-y-5" onSubmit={handleSubmit} noValidate>
                                <label className="block space-y-2 text-sm font-semibold" htmlFor="email">
                                    Correo electrónico
                                    <span className="relative block">
                                        <Mail className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-on-surface-variant" />
                                        <Input
                                            id="email"
                                            type="email"
                                            autoComplete="email"
                                            value={email}
                                            onChange={(event) => setEmail(event.target.value)}
                                            className="h-11 pl-10"
                                            placeholder="nombre@asociacion.cr"
                                            required
                                        />
                                    </span>
                                </label>

                                <label className="block space-y-2 text-sm font-semibold" htmlFor="password">
                                    Contraseña
                                    <span className="relative block">
                                        <LockKeyhole className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-on-surface-variant" />
                                        <Input
                                            id="password"
                                            type="password"
                                            autoComplete="current-password"
                                            value={password}
                                            onChange={(event) => setPassword(event.target.value)}
                                            className="h-11 pl-10"
                                            placeholder="••••••••"
                                            required
                                        />
                                    </span>
                                </label>

                                {error && (submitted || status === 'restore-error') && (
                                    <p className="rounded-lg border border-error/30 bg-error-container/40 px-3 py-2 text-sm text-on-error-container" role="alert">
                                        {error}
                                    </p>
                                )}

                                {status === 'restore-error' && (
                                    <Button className="w-full" type="button" variant="outline" onClick={() => void retrySessionRestore()}>
                                        Reintentar restauración de sesión
                                    </Button>
                                )}

                                <Button className="h-11 w-full" type="submit" disabled={isSubmitting}>
                                    {isSubmitting ? 'Validando acceso...' : 'Entrar'}
                                </Button>
                            </form>
                        </div>
                    </div>
                </section>
            </div>
        </main>
    )
}

export const Route = createFileRoute('/login')({
    component: LoginPage,
})
