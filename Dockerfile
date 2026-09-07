# ------------------------------------------------------------------------------
# Build Stage
# ------------------------------------------------------------------------------
FROM node:22-bookworm-slim AS builder

WORKDIR /app

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Copy workspace configuration and dependency manifests
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml* .npmrc* ./
COPY apps/api/package.json ./apps/api/
COPY apps/web/package.json ./apps/web/
COPY packages/constants/package.json ./packages/constants/
COPY packages/db/package.json ./packages/db/
COPY packages/executors/package.json ./packages/executors/
COPY packages/pricing/package.json ./packages/pricing/
COPY packages/providers/package.json ./packages/providers/
COPY packages/translator/package.json ./packages/translator/
COPY packages/types/package.json ./packages/types/

# Install all dependencies (including devDependencies required for build)
RUN pnpm install --no-frozen-lockfile

# Copy full source code
COPY . .

# Build all packages and applications (types, db, executors, web, api)
RUN pnpm run build

# ------------------------------------------------------------------------------
# Production Runner Stage
# ------------------------------------------------------------------------------
FROM node:22-bookworm-slim AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Create directory for persistent SQLite database (Railway Volume mount target)
RUN mkdir -p /data

# Copy workspace configuration and dependency manifests
COPY pnpm-workspace.yaml package.json pnpm-lock.yaml* .npmrc* ./
COPY apps/api/package.json ./apps/api/
COPY apps/web/package.json ./apps/web/
COPY packages/constants/package.json ./packages/constants/
COPY packages/db/package.json ./packages/db/
COPY packages/executors/package.json ./packages/executors/
COPY packages/pricing/package.json ./packages/pricing/
COPY packages/providers/package.json ./packages/providers/
COPY packages/translator/package.json ./packages/translator/
COPY packages/types/package.json ./packages/types/

# Install only production dependencies
RUN pnpm install --prod --no-frozen-lockfile

# Copy compiled outputs from builder
COPY --from=builder /app/packages/constants/dist ./packages/constants/dist
COPY --from=builder /app/packages/db/dist ./packages/db/dist
COPY --from=builder /app/packages/executors/dist ./packages/executors/dist
COPY --from=builder /app/packages/pricing/dist ./packages/pricing/dist
COPY --from=builder /app/packages/providers/dist ./packages/providers/dist
COPY --from=builder /app/packages/translator/dist ./packages/translator/dist
COPY --from=builder /app/packages/types/dist ./packages/types/dist
COPY --from=builder /app/apps/web/dist ./apps/web/dist
COPY --from=builder /app/apps/api/dist ./apps/api/dist

# Expose Gateway port (Railway overrides PORT dynamically)
EXPOSE 3000

# Persist database storage
VOLUME ["/data"]

# Healthcheck for container runners
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://localhost:' + (process.env.PORT || 3000) + '/health').then(r => r.ok ? process.exit(0) : process.exit(1)).catch(() => process.exit(1))"

CMD ["node", "apps/api/dist/index.js"]
