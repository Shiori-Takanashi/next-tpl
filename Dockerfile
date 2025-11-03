# 本番用マルチステージビルド
FROM node:22.11.0-alpine AS deps
# 依存関係のインストール
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production --frozen-lockfile

FROM node:22.11.0-alpine AS builder
# ビルドステージ
WORKDIR /app
COPY package*.json ./
RUN npm ci --frozen-lockfile

COPY . .
# 本番ビルド
ENV NODE_ENV=production
RUN npm run build

FROM node:22.11.0-alpine AS runner
# 実行ステージ
WORKDIR /app

# セキュリティ: 非rootユーザーを作成
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# 必要なファイルのみコピー
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# ユーザーとパーミッション設定
USER nextjs

# 本番環境変数
ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

CMD ["node", "server.js"]
