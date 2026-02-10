# Prompts de generación de código

<!-- Prompts reutilizables para que la IA genere código alineado con el proyecto. -->

## Backend (Node.js)
- Usar TypeScript estricto.
- Rutas en `apps/api`: agrupar por dominio (auth, loans, payments, etc.).
- Validación con Zod/Joi según estándar del proyecto.
- Respuestas con códigos HTTP y formato JSON consistente.

## Frontend (React + TypeScript)
- Componentes funcionales con hooks.
- Estado: _especificar (Context, Redux, React Query, etc.)_.
- Estilos: _especificar (Tailwind, CSS modules, etc.)_.
- Accesibilidad y manejo de loading/error en todas las pantallas.

## Workers
- Jobs idempotentes cuando sea posible.
- Logs estructurados y correlación por `jobId` / `requestId`.
- Reintentos y dead-letter según `event-schemas` y reglas de negocio.

## Convenciones
- Nombres en inglés en código; textos de UI según locale.
- Variables de entorno documentadas en `api-integrations.md` y `.env.example`.
