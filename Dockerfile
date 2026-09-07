# ------------------------------------------------------------------------------
# Build Stage
# ------------------------------------------------------------------------------
FROM node:22-bookworm-slim AS builder

WORKDIR /app

# Install pnpm reliably
RUN npm install -g pnpm@latest

# Copy repository
COPY . .

# Install dependencies (respecting pnpm-workspace.yaml & workspace:* references)
RUN pnpm install --no-frozen-lockfile

# Build all packages sequentially to ensure proper dependency order
RUN pnpm run build

# Prune development dependencies to minimize final image size
RUN pnpm prune --prod

# ------------------------------------------------------------------------------
# Production Runner Stage
# ------------------------------------------------------------------------------
FROM node:22-bookworm-slim AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Create directory for persistent SQLite database (Railway Volume mount target)
RUN mkdir -p /data

# Copy production files and build artifacts from builder
COPY --from=builder /app /app

# Expose Gateway port (Railway overrides PORT dynamically)
EXPOSE 3000

# Persist database storage
VOLUME ["/data"]

# Healthcheck for container runners
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://localhost:' + (process.env.PORT || 3000) + '/health').then(r => r.ok ? process.exit(0) : process.exit(1)).catch(() => process.exit(1))"

CMD ["node", "apps/api/dist/index.js"]
