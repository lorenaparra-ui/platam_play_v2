### Factores Críticos de Éxito

1. **Contexto es Rey:** 
   - 70% del valor viene de mantener contexto actualizado en carpeta `.ai/`
   - Inversión inicial: 2-3 días documentando requerimientos/arquitectura
   - Payoff: Todo el ciclo de vida del proyecto

2. **Prompts de Alta Calidad:**
   - Prompts específicos generan código 5x mejor que prompts genéricos
   - Template de prompt ahorró 40% tiempo de iteración (menos back-and-forth)

3. **Validación Humana No-Negociable:**
   - 100% del código IA debe ser revisado por humano senior
   - Security, compliance y lógica de negocio crítica: SIEMPRE validar

4. **Iteración Continua:**
   - Actualizar contexto cada sprint
   - Mejorar prompts basándose en outputs previos
   - Compartir best practices entre equipo
---

## Prompt Template Final: "Iniciar Proyecto Fintech"
```
"Eres el arquitecto senior de una nueva plataforma fintech BNPL.

# Contexto del Proyecto
- Nombre: [Nombre de la startup]
- Mercado objetivo: [País/región]
- Diferenciador: [Qué nos hace únicos]
- Fase: Pre-seed

# Stack Decidido
- Backend: Node.js + TypeScript + PostgreSQL
- Frontend: React + TypeScript + Tailwind + Shadcn/ui
- Infraestructura: AWS (ECS Fargate, RDS, S3, CloudWatch)
- Integraciones: Payvalida, Twilio, ZapSign, n8n

# Tu Misión
Crear la estructura completa del proyecto siguiendo las mejores prácticas:

1. Genera estructura de carpetas (monorepo Turborepo)
2. Configura herramientas (TypeScript, ESLint, Prettier, Jest, Docker)
3. Crea carpeta @.ai/context con documentos base:
   - requirements.md (template para llenar)
   - architecture.md (decisiones arquitecturales)
   - business-rules.md (template de reglas BNPL)
4. Schema inicial de DB (usuarios, préstamos, pagos, transacciones)
5. Configuración AWS (Terraform básico)
6. CI/CD pipeline (GitHub Actions)
7. README.md completo con instrucciones de setup

# Requisitos
- Seguir principios del documento que te compartí
- Código production-ready desde día 1
- Documentación clara para desarrolladores que se unan después
- Security by default (secrets en AWS Secrets Manager, rate limiting, etc.)

# Entregables
1. Estructura de proyecto completa
2. Archivos de configuración listos
3. Schema DB con migraciones
4. Scripts de setup (setup.sh para local dev)
5. Documentación de arquitectura (diagrams en Mermaid)

Comienza generando el plan de implementación y luego ejecuta paso a paso."