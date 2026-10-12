import { expect, test } from '@playwright/test'

const viewports = [
  { name: 'desktop 1334px', width: 1334, height: 900, minimumFieldWidth: 300 },
  { name: 'mobile 390px', width: 390, height: 844, minimumFieldWidth: 300 },
]

for (const viewport of viewports) {
  test(`mantiene campos utilizables e interactivos en ${viewport.name}`, async ({ page }) => {
    await page.setViewportSize({ width: viewport.width, height: viewport.height })
    await page.goto('/login')

    const email = page.getByLabel('Correo electrónico')
    const password = page.getByLabel('Contraseña')

    const dimensions = await Promise.all([email.boundingBox(), password.boundingBox()])
    console.log(`${viewport.name}: email=${dimensions[0]?.width}x${dimensions[0]?.height}, password=${dimensions[1]?.width}x${dimensions[1]?.height}`)

    for (const dimension of dimensions) {
      expect(dimension?.width).toBeGreaterThanOrEqual(viewport.minimumFieldWidth)
      expect(dimension?.height).toBeGreaterThanOrEqual(44)
    }

    for (const [field, value] of [
      [email, 'persona@asociacion.cr'],
      [password, 'secreto-normal-123'],
    ] as const) {
      await field.click()
      await expect(field).toBeFocused()
      await field.fill(value)
      await expect(field).toHaveValue(value)
    }
  })
}
