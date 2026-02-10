# Checklist de revisión de código

<!-- Criterios de validación para PRs y revisión por IA. -->

## General
- [ ] Código compila / tests pasan
- [ ] Sin secretos ni datos sensibles en código
- [ ] Cambios alineados con `architecture.md` y `business-rules.md`

## Backend
- [ ] Validación de entrada en todos los endpoints
- [ ] Errores mapeados a códigos HTTP correctos
- [ ] Transacciones DB donde aplique (consistencia)
- [ ] Logs sin PII innecesario

## Frontend
- [ ] Estados de loading y error manejados
- [ ] Accesibilidad básica (labels, contraste, foco)
- [ ] Sin dependencias innecesarias

## Integraciones
- [ ] Clientes en `packages/integration-clients`
- [ ] Reintentos y timeouts configurados
- [ ] Documentación actualizada en `api-integrations.md`

## Schemas y contratos
- [ ] Cambios en DB reflejados en `database-schema.sql` y migraciones
- [ ] Cambios de API en `api-contracts.yaml`
- [ ] Eventos nuevos en `event-schemas.json`
