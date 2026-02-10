# ----------------------------------------
# Stage 1: Builder (Compilación)
# ----------------------------------------
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Copiamos solo los archivos de dependencias primero para aprovechar la caché de Docker
COPY package*.json ./

# Instalación limpia de dependencias (npm ci es más rápido y estricto que npm install)
RUN npm ci

# Copiamos el código fuente
COPY . .

# Construimos la aplicación NestJS
RUN npm run build

# Eliminamos dependencias de desarrollo para aligerar la imagen final
RUN npm prune --production

# ----------------------------------------
# Stage 2: Production (Ejecución)
# ----------------------------------------
FROM node:20-alpine AS runner

# Variable de entorno para optimizar Node.js
ENV NODE_ENV=production

WORKDIR /usr/src/app

# Crear usuario y grupo de sistema para no correr como root (Seguridad)
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copiamos solo lo necesario del stage builder
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/package.json ./package.json

# Usamos el usuario sin privilegios
USER nodejs

# Exponemos el puerto (informativo)
EXPOSE 3000

# Healthcheck para orquestadores (Docker Compose / ECS / K8s)
# Nota: Asegúrate de que tu app responda 200 OK en / (o crea un endpoint /health)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Comando de inicio
CMD ["node", "dist/main"]