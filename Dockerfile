# ------------------------------------------------------------------------------
# Build Stage
# ------------------------------------------------------------------------------
FROM node:22-bookworm-slim AS builder

WORKDIR /app

# Copy repository
COPY . .

# Install dependencies using npm (handles workspaces natively, no build script blocking)
RUN npm install

# Install pnpm for workspace-aware build commands
RUN npm install -g pnpm@latest

# Build all packages sequentially
RUN pnpm run build

# Prune development dependencies
RUN npm prune --production

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

CMD ["node", "apps/api/dist/index.js"]
