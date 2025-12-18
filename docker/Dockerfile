# Stage 1: Dependencies
FROM node:22-bookworm-slim AS deps

WORKDIR /app

COPY package.json yarn.lock* package-lock.json* ./

RUN if [ -f yarn.lock ]; then \
    yarn install --frozen-lockfile; \
    elif [ -f package-lock.json ]; then \
    npm ci; \
    else \
    npm install; \
    fi

# Stage 2: Builder
FROM node:22-bookworm-slim AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

# Stage 3: Production dependencies (Alpine compatible)
FROM node:22-alpine AS prod-deps

RUN apk add --no-cache python3 make g++ libc6-compat

WORKDIR /app

COPY package.json yarn.lock* package-lock.json* ./

RUN if [ -f yarn.lock ]; then \
    yarn install --frozen-lockfile --production; \
    elif [ -f package-lock.json ]; then \
    npm ci --omit=dev; \
    else \
    npm install --omit=dev; \
    fi

# Stage 4: Production runner
FROM node:22-alpine AS runner

RUN apk add --no-cache dumb-init libc6-compat && rm -rf /var/cache/apk/*

RUN addgroup --system --gid 1001 nodejs && adduser --system --uid 1001 nestjs

WORKDIR /app

RUN chown -R nestjs:nodejs /app

COPY --from=builder --chown=nestjs:nodejs /app/dist ./dist
COPY --from=prod-deps --chown=nestjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nestjs:nodejs /app/package.json ./

RUN mkdir -p /app/logs && chown -R nestjs:nodejs /app/logs

USER nestjs

EXPOSE 5000

ENV NODE_ENV=production
ENV APP_PORT=5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:5000/api/v1/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))" || exit 1

ENTRYPOINT ["dumb-init", "--"]

CMD ["node", "dist/main"]
