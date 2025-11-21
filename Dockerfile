# --- Builder ---
FROM node:22.11.0-alpine AS builder
WORKDIR /app

# Install ALL deps (dev + prod)
COPY package*.json ./
RUN npm ci --frozen-lockfile

# Copy source
COPY . .

# Build Next.js
RUN npm run build

# Prune dev deps
RUN npm prune --omit=dev


# --- Runner ---
FROM node:22.11.0-alpine AS runner
WORKDIR /app

# Non-root user for security
RUN addgroup -S nodejs && adduser -S nextjs -G nodejs

# Copy final production files
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

USER nextjs

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O - http://localhost:3000/api/health || exit 1

CMD ["node", "server.js"]
