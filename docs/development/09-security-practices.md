# 09. セキュリティとベストプラクティス

**作成日**: 2025-10-26
**目的**: Next.js学習テンプレートにおけるセキュリティ実装とベストプラクティス

## 🛡️ セキュリティの基本方針

### 学習段階に応じたセキュリティ実装

#### レベル1: 基本セキュリティ（必須）
- 環境変数の適切な管理
- XSS対策の基本実装
- HTTPS強制とセキュリティヘッダー
- 依存関係の脆弱性管理

#### レベル2: 実践セキュリティ（推奨）
- CSRFトークン実装
- 認証・認可の実装
- 入力値検証とサニタイゼーション
- ログ監視とアラート

#### レベル3: 高度なセキュリティ（上級）
- セキュリティスキャン自動化
- 侵入検知システム
- ゼロトラスト原則実装
- セキュリティ監査ログ

## 🔐 環境変数とシークレット管理

### 安全な環境変数設計

#### 1. 分類と命名規則
```bash
# 公開可能（クライアントサイド）
NEXT_PUBLIC_APP_NAME="Next.js Learning Template"
NEXT_PUBLIC_API_URL="https://api.example.com"
NEXT_PUBLIC_GA_ID="G-XXXXXXXXXX"

# 秘密情報（サーバーサイドのみ）
DATABASE_URL="postgresql://user:password@localhost:5432/db"
API_SECRET_KEY="super-secret-key-here"
JWT_SECRET="jwt-signing-secret"

# 開発環境用
DEV_DATABASE_URL="postgresql://dev:dev@localhost:5432/dev_db"
DEBUG="true"
LOG_LEVEL="debug"
```

#### 2. .env ファイル階層管理
```bash
# 優先順位（高い順）
.env.local          # ローカル開発用（gitignore対象）
.env.development    # 開発環境用
.env.production     # 本番環境用
.env                # 全環境共通（基本設定のみ）
```

#### 3. 環境変数検証
```javascript
// lib/env.js
import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  API_SECRET_KEY: z.string().min(32),
  NEXT_PUBLIC_APP_NAME: z.string(),
  NODE_ENV: z.enum(['development', 'production', 'test'])
});

export const env = envSchema.parse(process.env);
```

## 🔒 認証・認可の実装例

### NextAuth.js 統合

#### 1. 基本設定
```javascript
// pages/api/auth/[...nextauth].js
import NextAuth from 'next-auth';
import GoogleProvider from 'next-auth/providers/google';
import { PrismaAdapter } from '@next-auth/prisma-adapter';
import { prisma } from '../../../lib/prisma';

export default NextAuth({
  adapter: PrismaAdapter(prisma),
  providers: [
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    }),
  ],
  session: {
    strategy: 'jwt',
    maxAge: 30 * 24 * 60 * 60, // 30 days
  },
  jwt: {
    secret: process.env.JWT_SECRET,
  },
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.role = user.role;
      }
      return token;
    },
    async session({ session, token }) {
      session.user.id = token.sub;
      session.user.role = token.role;
      return session;
    },
  },
  pages: {
    signIn: '/auth/signin',
    error: '/auth/error',
  },
});
```

#### 2. 認証ミドルウェア
```javascript
// middleware.js
import { withAuth } from 'next-auth/middleware';

export default withAuth(
  function middleware(req) {
    // 追加の認証ロジック
    const { pathname } = req.nextUrl;
    const { token } = req.nextauth;

    // 管理者ページのアクセス制御
    if (pathname.startsWith('/admin') && token?.role !== 'admin') {
      return new Response('Forbidden', { status: 403 });
    }
  },
  {
    callbacks: {
      authorized: ({ token, req }) => {
        const { pathname } = req.nextUrl;

        // 公開ページは認証不要
        if (pathname === '/' || pathname.startsWith('/public')) {
          return true;
        }

        // その他は認証必須
        return !!token;
      },
    },
  }
);

export const config = {
  matcher: ['/dashboard/:path*', '/admin/:path*', '/api/private/:path*']
};
```

## 🚫 XSS・CSRF対策

### 1. XSS対策実装

#### Content Security Policy (CSP)
```javascript
// next.config.js
const nextConfig = {
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'Content-Security-Policy',
            value: [
              "default-src 'self'",
              "script-src 'self' 'unsafe-eval' 'unsafe-inline'",
              "style-src 'self' 'unsafe-inline'",
              "img-src 'self' data: https:",
              "font-src 'self'",
              "connect-src 'self' https://api.example.com",
            ].join('; ')
          }
        ]
      }
    ];
  }
};
```

#### 安全なHTML描画
```jsx
// components/SafeHTML.tsx
import DOMPurify from 'dompurify';

interface SafeHTMLProps {
  html: string;
  allowedTags?: string[];
}

export function SafeHTML({ html, allowedTags = ['b', 'i', 'em', 'strong'] }: SafeHTMLProps) {
  const cleanHTML = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: allowedTags,
    ALLOWED_ATTR: []
  });

  return <div dangerouslySetInnerHTML={{ __html: cleanHTML }} />;
}
```

### 2. CSRF対策

#### CSRFトークン実装
```javascript
// lib/csrf.js
import { randomBytes } from 'crypto';

export function generateCSRFToken() {
  return randomBytes(32).toString('hex');
}

export function validateCSRFToken(token, sessionToken) {
  return token === sessionToken;
}

// API ルートでの使用例
// pages/api/protected.js
export default async function handler(req, res) {
  if (req.method === 'POST') {
    const { csrfToken } = req.body;
    const sessionToken = req.session.csrfToken;

    if (!validateCSRFToken(csrfToken, sessionToken)) {
      return res.status(403).json({ error: 'Invalid CSRF token' });
    }
  }

  // 処理続行
}
```

## 🔍 入力値検証とサニタイゼーション

### Zodスキーマ活用

#### 1. APIエンドポイント検証
```javascript
// lib/schemas.js
import { z } from 'zod';

export const userSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().min(0).max(150),
  bio: z.string().max(500).optional()
});

export const createPostSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1).max(5000),
  tags: z.array(z.string()).max(10),
  isPublic: z.boolean()
});
```

#### 2. API ハンドラーでの使用
```javascript
// pages/api/users.js
import { userSchema } from '../../lib/schemas';

export default async function handler(req, res) {
  if (req.method === 'POST') {
    try {
      const validatedData = userSchema.parse(req.body);

      // データベース保存
      const user = await createUser(validatedData);

      res.status(201).json(user);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          error: 'Validation failed',
          details: error.errors
        });
      }

      res.status(500).json({ error: 'Internal server error' });
    }
  }
}
```

### 3. フロントエンド検証
```jsx
// components/UserForm.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { userSchema } from '../lib/schemas';

export function UserForm() {
  const {
    register,
    handleSubmit,
    formState: { errors }
  } = useForm({
    resolver: zodResolver(userSchema)
  });

  const onSubmit = async (data) => {
    try {
      const response = await fetch('/api/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      });

      if (!response.ok) {
        throw new Error('Failed to create user');
      }
    } catch (error) {
      console.error('Error:', error);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input
        {...register('name')}
        placeholder="Name"
      />
      {errors.name && <span>{errors.name.message}</span>}

      <input
        {...register('email')}
        type="email"
        placeholder="Email"
      />
      {errors.email && <span>{errors.email.message}</span>}

      <button type="submit">Submit</button>
    </form>
  );
}
```

## 📊 セキュリティ監視とログ

### 1. セキュリティログ実装

#### ログ構造化
```javascript
// lib/security-logger.js
import winston from 'winston';

const securityLogger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'security.log' }),
    new winston.transports.Console()
  ]
});

export function logSecurityEvent(event, details) {
  securityLogger.info({
    type: 'security_event',
    event,
    details,
    timestamp: new Date().toISOString(),
    userAgent: details.userAgent,
    ip: details.ip
  });
}

// 使用例
export function logFailedLogin(email, ip, userAgent) {
  logSecurityEvent('failed_login', {
    email,
    ip,
    userAgent,
    severity: 'medium'
  });
}
```

#### 2. 異常検知
```javascript
// lib/anomaly-detection.js
const MAX_LOGIN_ATTEMPTS = 5;
const TIME_WINDOW = 15 * 60 * 1000; // 15分

export class AnomalyDetector {
  constructor() {
    this.loginAttempts = new Map();
  }

  checkLoginAttempts(ip) {
    const now = Date.now();
    const attempts = this.loginAttempts.get(ip) || [];

    // 時間窓外の試行を削除
    const recentAttempts = attempts.filter(
      attempt => now - attempt < TIME_WINDOW
    );

    if (recentAttempts.length >= MAX_LOGIN_ATTEMPTS) {
      logSecurityEvent('brute_force_detected', {
        ip,
        attempts: recentAttempts.length,
        severity: 'high'
      });
      return false;
    }

    recentAttempts.push(now);
    this.loginAttempts.set(ip, recentAttempts);
    return true;
  }
}
```

## 🔧 依存関係セキュリティ管理

### 1. 自動スキャンとアップデート

#### package.json設定
```json
{
  "scripts": {
    "security:audit": "npm audit --audit-level=moderate",
    "security:fix": "npm audit fix",
    "security:check": "snyk test",
    "deps:update": "npx npm-check-updates -u"
  },
  "devDependencies": {
    "snyk": "^1.1200.0",
    "npm-check-updates": "^16.14.0"
  }
}
```

#### GitHub Actions ワークフロー
```yaml
# .github/workflows/security.yml
name: Security Scan

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * 1' # 毎週月曜日 2:00 AM

jobs:
  security:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high

    - name: Run npm audit
      run: npm audit --audit-level=moderate
```

### 2. 依存関係の最小化

#### パッケージサイズ分析
```bash
# 番号付きリスト用のスクリプト
npm run analyze
npx webpack-bundle-analyzer .next/analyze/bundle/client.html
```

#### Tree-shaking最適化
```javascript
// next.config.js
const nextConfig = {
  experimental: {
    optimizePackageImports: ['lodash', 'date-fns']
  },
  webpack: (config) => {
    config.optimization.usedExports = true;
    return config;
  }
};
```

## 🎓 学習段階別セキュリティ実装ガイド

### 初級者（基本セキュリティ）
1. ✅ 環境変数の適切な管理
2. ✅ XSS対策（基本的なエスケープ）
3. ✅ HTTPS強制設定
4. ⏳ 依存関係の脆弱性チェック

### 中級者（実践セキュリティ）
1. ⏳ 認証・認可システム導入
2. ⏳ 入力値検証の徹底
3. ⏳ セキュリティヘッダーの実装
4. ⏳ ログ監視システム構築

### 上級者（高度なセキュリティ）
1. ⏳ セキュリティスキャン自動化
2. ⏳ 異常検知システム
3. ⏳ 侵入テスト実装
4. ⏳ セキュリティ監査ログ

## 📋 セキュリティチェックリスト

### デプロイ前チェック
- [ ] 環境変数の機密情報漏洩確認
- [ ] 依存関係の脆弱性スキャン
- [ ] CSPヘッダーの設定確認
- [ ] 認証・認可の動作テスト
- [ ] 入力値検証の網羅性確認

### 定期監査項目
- [ ] アクセスログの異常検知
- [ ] 依存関係のアップデート
- [ ] セキュリティパッチの適用
- [ ] 認証トークンの有効期限管理
- [ ] バックアップの暗号化確認

このセキュリティ実装により、学習テンプレートでありながら本格的なセキュリティ対策を体験でき、実際のプロダクション環境でも適用可能な知識を習得できます。
