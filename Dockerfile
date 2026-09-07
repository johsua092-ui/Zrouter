FROM node:22-bookworm-slim AS builder
WORKDIR /app
RUN npm install -g pnpm@latest
COPY . .
RUN pnpm install --no-frozen-lockfile
RUN pnpm run build
RUN pnpm prune --prod

FROM node:22-bookworm-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000
RUN mkdir -p /data
COPY --from=builder /app /app
EXPOSE 3000
CMD ["node", "apps/api/dist/index.js"]
