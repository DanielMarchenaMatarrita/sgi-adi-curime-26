FROM node:22-bookworm-slim

WORKDIR /opt/validator

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY backend/package.json backend/tsconfig.json backend/tsconfig.build.json backend/jest.config.js ./backend/
COPY backend/src ./backend/src
COPY backend/test ./backend/test
COPY database/prisma ./database/prisma

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssl \
    && rm -rf /var/lib/apt/lists/* \
    && corepack enable \
    && pnpm install --frozen-lockfile \
    && pnpm exec prisma generate --schema database/prisma/schema.prisma \
    && pnpm --dir backend exec tsc -p tsconfig.build.json
