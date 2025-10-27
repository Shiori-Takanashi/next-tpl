# プロダクション環境デプロイ戦略

## 概要
Next.js学習テンプレートの本番環境デプロイに関する包括的戦略記録

## デプロイメント方式の比較

### Vercel（推奨）
```bash
# Vercel CLI使用
npm i -g vercel
vercel

# または GitHub連携での自動デプロイ
# 1. GitHubリポジトリ作成
# 2. Vercelでリポジトリ連携
# 3. 自動ビルド・デプロイ
```

#### メリット
- Next.js開発元による最適化
- Zero-config deployment
- Edge Functions対応
- 自動プレビューデプロイ

#### 設定例
```javascript
// vercel.json
{
  "version": 2,
  "name": "next-tpl",
  "builds": [
    {
      "src": "package.json",
      "use": "@vercel/next"
    }
  ],
  "env": {
    "NODE_ENV": "production"
  },
  "regions": ["nrt1"]  // 東京リージョン
}
```

### Netlify
```bash
# Netlify CLI
npm install -g netlify-cli
netlify deploy --build

# 本番デプロイ
netlify deploy --prod --build
```

#### 設定
```toml
# netlify.toml
[build]
  command = "npm run build"
  publish = ".next"

[build.environment]
  NODE_VERSION = "22.11.0"

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
```

### Docker本番デプロイ

#### マルチステージDockerfile最適化
```dockerfile
# Dockerfile.production
FROM node:22.11.0-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:22.11.0-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:22.11.0-alpine AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000
ENV PORT 3000

CMD ["node", "server.js"]
```

#### Docker Compose本番環境
```yaml
# docker-compose.production.yml
version: '3.8'

services:
  next-app:
    build:
      context: .
      dockerfile: Dockerfile.production
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - next-app
    restart: unless-stopped
```

## CI/CD パイプライン

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '22.11.0'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm run test

      - name: Type check
        run: npm run type-check

      - name: Lint
        run: npm run lint

      - name: Build
        run: npm run build

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          vercel-args: '--prod'
```

### GitLab CI/CD
```yaml
# .gitlab-ci.yml
stages:
  - test
  - build
  - deploy

variables:
  NODE_VERSION: "22.11.0"

cache:
  paths:
    - node_modules/
    - .next/cache/

test:
  stage: test
  image: node:$NODE_VERSION
  script:
    - npm ci
    - npm run test
    - npm run type-check
    - npm run lint

build:
  stage: build
  image: node:$NODE_VERSION
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - .next/
    expire_in: 1 hour

deploy:
  stage: deploy
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  only:
    - main
```

## パフォーマンス最適化

### Next.js設定最適化
```typescript
// next.config.ts - 本番最適化
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  // 本番ビルド最適化
  output: 'standalone',

  // 画像最適化
  images: {
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
  },

  // 実験的機能
  experimental: {
    optimizeCss: true,
    optimizePackageImports: ['lucide-react'],
  },

  // セキュリティヘッダー
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin',
          },
        ],
      },
    ];
  },

  // リダイレクト設定
  async redirects() {
    return [
      {
        source: '/home',
        destination: '/',
        permanent: true,
      },
    ];
  },
};

export default nextConfig;
```

### Nginx設定
```nginx
# nginx.conf - リバースプロキシ設定
events {
    worker_connections 1024;
}

http {
    upstream nextjs {
        server next-app:3000;
    }

    # Gzip圧縮
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

    # キャッシュ設定
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    server {
        listen 80;
        server_name example.com;

        # HTTPS リダイレクト
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name example.com;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        location / {
            proxy_pass http://nextjs;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
        }
    }
}
```

## 監視とロギング

### ヘルスチェックAPI
```typescript
// app/api/health/route.ts
import { NextResponse } from 'next/server';

export async function GET() {
  try {
    // システムチェック
    const checks = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      version: process.env.npm_package_version,
      node: process.version,
      memory: process.memoryUsage(),
      uptime: process.uptime(),
    };

    return NextResponse.json(checks);
  } catch (error) {
    return NextResponse.json(
      { status: 'unhealthy', error: 'Health check failed' },
      { status: 503 }
    );
  }
}
```

### ログ設定
```typescript
// lib/logger.ts
interface LogEntry {
  level: 'info' | 'warn' | 'error';
  message: string;
  timestamp: string;
  meta?: object;
}

export const logger = {
  info: (message: string, meta?: object) => {
    const entry: LogEntry = {
      level: 'info',
      message,
      timestamp: new Date().toISOString(),
      meta,
    };

    if (process.env.NODE_ENV === 'production') {
      console.log(JSON.stringify(entry));
    } else {
      console.log(`[INFO] ${message}`, meta);
    }
  },

  error: (message: string, error?: Error) => {
    const entry: LogEntry = {
      level: 'error',
      message,
      timestamp: new Date().toISOString(),
      meta: error ? { stack: error.stack } : undefined,
    };

    if (process.env.NODE_ENV === 'production') {
      console.error(JSON.stringify(entry));
    } else {
      console.error(`[ERROR] ${message}`, error);
    }
  },
};
```

## セキュリティ設定

### 環境変数管理
```bash
# .env.production
NODE_ENV=production
NEXT_TELEMETRY_DISABLED=1

# データベース
DATABASE_URL=postgresql://user:password@host:5432/dbname

# 認証
AUTH_SECRET=your-super-secure-secret
JWT_SECRET=another-secure-secret

# 外部API
API_KEY=your-api-key
```

### セキュリティミドルウェア
```typescript
// middleware.ts - セキュリティ強化
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const response = NextResponse.next();

  // セキュリティヘッダー設定
  response.headers.set('X-Frame-Options', 'DENY');
  response.headers.set('X-Content-Type-Options', 'nosniff');
  response.headers.set('Referrer-Policy', 'origin-when-cross-origin');
  response.headers.set(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self' 'unsafe-eval'; style-src 'self' 'unsafe-inline';"
  );

  return response;
}
```

## バックアップ戦略

### データベースバックアップ
```bash
#!/bin/bash
# backup.sh
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"

# PostgreSQL バックアップ
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME > $BACKUP_DIR/db_backup_$DATE.sql

# 古いバックアップ削除（30日以上）
find $BACKUP_DIR -name "db_backup_*.sql" -mtime +30 -delete
```

### ファイルバックアップ
```yaml
# backup-cronjob.yml (Kubernetes)
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
spec:
  schedule: "0 2 * * *"  # 毎日午前2時
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:15
            command:
            - /bin/bash
            - -c
            - pg_dump $DATABASE_URL > /backup/backup-$(date +%Y%m%d).sql
          restartPolicy: OnFailure
```

## デプロイメントチェックリスト

### 事前チェック
- [ ] 全テスト通過
- [ ] 型チェック通過
- [ ] Lint エラーなし
- [ ] ビルド成功
- [ ] セキュリティ監査通過

### 本番デプロイ後
- [ ] ヘルスチェック確認
- [ ] パフォーマンス測定
- [ ] ログ監視開始
- [ ] 監視アラート確認
- [ ] ロールバック手順確認

---

**作成**: 2025/10/27
**対象**: プロダクション環境管理者
**更新**: デプロイ戦略変更時
