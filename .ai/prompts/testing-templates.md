# Plantillas para tests

<!-- Plantillas reutilizables para unit, integration y e2e. -->

## Unit (Jest / Vitest)
```ts
describe('ModuleName', () => {
  describe('functionName', () => {
    it('should [comportamiento esperado] when [condición]', () => {
      // arrange
      // act
      // assert
    });
  });
});
```

## Integración API
- Setup: DB en estado conocido (seeds o migrations).
- Ejecutar request contra app (supertest o similar).
- Assert status, body y efectos en DB si aplica.
- Limpiar datos de prueba al final.

## Integración con cliente externo
- Usar mocks del cliente (nock, msw o stub).
- Probar flujo happy path y al menos un error (4xx/5xx).
- No llamar APIs reales en CI salvo en jobs explícitos.

## E2E (Playwright / Cypress)
- Un flujo crítico por spec (ej.: onboarding completo, solicitud de préstamo).
- Datos de prueba aislados; no depender de datos de otros runs.
- Screenshots o video en fallo según configuración.
