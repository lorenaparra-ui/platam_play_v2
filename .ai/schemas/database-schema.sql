-- Schema PostgreSQL de referencia
-- Mantener alineado con Prisma/TypeORM y migraciones reales.
-- Este archivo es la fuente de verdad documental; las migraciones lo implementan.

-- Ejemplo mínimo; reemplazar con el modelo real del proyecto.

-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- users (ejemplo)
-- CREATE TABLE users (
--   id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--   email      VARCHAR(255) NOT NULL UNIQUE,
--   name       VARCHAR(255),
--   created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
--   updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
-- );

-- loans (ejemplo)
-- CREATE TABLE loans (
--   id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--   user_id    UUID NOT NULL REFERENCES users(id),
--   amount     DECIMAL(19,4) NOT NULL,
--   status     VARCHAR(50) NOT NULL,
--   created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
--   updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
-- );

-- Añadir aquí todas las tablas, índices y constraints del proyecto.
