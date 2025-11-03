# 08. テストとCI/CD戦略

**作成日**: 2025-10-26 **目的**: 学習テンプレートのテスト戦略とCI/CD実装指針

## 🧪 テスト戦略の設計

### 学習段階に応じたテスト導入

#### Phase 1: 基礎学習段階

```bash
# 手動テスト中心
npm run dev          # 開発サーバー確認
npm run build        # ビルド成功確認
npm run lint         # コード品質確認
```

#### Phase 2: 実践学習段階

```json
// package.json 追加予定
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  },
  "devDependencies": {
    "@testing-library/react": "^13.4.0",
    "@testing-library/jest-dom": "^5.16.5",
    "jest": "^29.7.0",
    "jest-environment-jsdom": "^29.7.0"
  }
}
```

#### Phase 3: プロジェクト開発段階

```json
// E2E テスト追加
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui"
  },
  "devDependencies": {
    "@playwright/test": "^1.40.0"
  }
}
```

## 🚀 CI/CD パイプライン設計

### GitHub Actions ワークフロー構成

#### 1. 基本検証ワークフロー

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [18.x, 20.x, 22.x]

    steps:
      - uses: actions/checkout@v4

      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run type check
        run: npm run type-check

      - name: Run tests
        run: npm run test

      - name: Build application
        run: npm run build
```

#### 2. Docker ビルドテスト

```yaml
# .github/workflows/docker.yml
name: Docker Build Test

on:
  push:
    branches: [main]

jobs:
  docker-build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Build Docker image (dev)
        run: docker build -f Dockerfile.dev -t next-tpl:dev .

      - name: Build Docker image (prod)
        run: docker build -f Dockerfile -t next-tpl:prod .

      - name: Test Docker containers
        run: |
          docker run -d -p 3000:3000 next-tpl:prod
          sleep 10
          curl -f http://localhost:3000 || exit 1
```

### 自動デプロイ戦略

#### Vercel連携（推奨）

```json
// vercel.json
{
  "framework": "nextjs",
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm ci",
  "env": {
    "NEXT_PUBLIC_APP_NAME": "Next.js Learning Template"
  }
}
```

#### GitHub Pages（静的エクスポート）

```javascript
// next.config.ts での設定例
const nextConfig = {
  output: "export",
  basePath: process.env.NODE_ENV === "production" ? "/next-tpl" : "",
  images: {
    unoptimized: true,
  },
};
```

## 🔍 品質管理ツール統合

### 1. Husky + lint-staged

```json
// package.json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md}": ["prettier --write"]
  },
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged",
      "pre-push": "npm run type-check && npm run test"
    }
  }
}
```

### 2. Prettier 設定

```json
// .prettierrc
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
```

### 3. VS Code 設定

```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.preferences.importModuleSpecifier": "relative"
}
```

## 📊 メトリクス管理

### ビルドサイズ監視

```json
// package.json
{
  "scripts": {
    "analyze": "cross-env ANALYZE=true npm run build",
    "analyze:server": "cross-env BUNDLE_ANALYZE=server npm run build",
    "analyze:browser": "cross-env BUNDLE_ANALYZE=browser npm run build"
  }
}
```

### パフォーマンス測定

```javascript
// scripts/lighthouse.js
const lighthouse = require("lighthouse");
const chromeLauncher = require("chrome-launcher");

async function runLighthouse() {
  const chrome = await chromeLauncher.launch({ chromeFlags: ["--headless"] });
  const options = { logLevel: "info", output: "html", port: chrome.port };
  const runnerResult = await lighthouse("http://localhost:3000", options);

  // レポート保存
  console.log(
    "Performance score:",
    runnerResult.lhr.categories.performance.score * 100
  );

  await chrome.kill();
}

runLighthouse();
```

## 🛡️ セキュリティ対策

### 1. 依存関係脆弱性チェック

```json
// package.json
{
  "scripts": {
    "security:audit": "npm audit",
    "security:fix": "npm audit fix",
    "security:check": "npm audit --audit-level moderate"
  }
}
```

### 2. GitHub Security機能活用

- Dependabot による自動アップデート
- CodeQL による静的解析
- Secret scanning による機密情報検出

### 3. セキュリティヘッダー設定

```javascript
// next.config.ts
const nextConfig = {
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: [
          {
            key: "X-Content-Type-Options",
            value: "nosniff",
          },
          {
            key: "X-Frame-Options",
            value: "DENY",
          },
          {
            key: "X-XSS-Protection",
            value: "1; mode=block",
          },
        ],
      },
    ];
  },
};
```

## 📈 モニタリング戦略

### 1. アプリケーションモニタリング

```javascript
// lib/analytics.js
export function trackEvent(action, category, label, value) {
  if (typeof window !== "undefined" && window.gtag) {
    window.gtag("event", action, {
      event_category: category,
      event_label: label,
      value: value,
    });
  }
}

export function trackPageView(url) {
  if (typeof window !== "undefined" && window.gtag) {
    window.gtag("config", process.env.NEXT_PUBLIC_GA_ID, {
      page_path: url,
    });
  }
}
```

### 2. エラートラッキング

```javascript
// lib/sentry.js (例)
import * as Sentry from "@sentry/nextjs";

if (process.env.NODE_ENV === "production") {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    tracesSampleRate: 0.1,
  });
}
```

## 🎓 学習段階別テスト導入ガイド

### 初級者向け（Phase 1）

1. **手動テスト**: ブラウザでの動作確認
2. **リンター**: ESLintでコード品質確認
3. **ビルドテスト**: 本番ビルドの成功確認

### 中級者向け（Phase 2）

1. **単体テスト**: コンポーネントのテスト
2. **統合テスト**: ページ全体のテスト
3. **カバレッジ**: テストカバレッジの確認

### 上級者向け（Phase 3）

1. **E2Eテスト**: ユーザーシナリオのテスト
2. **パフォーマンステスト**: 速度・メモリ使用量測定
3. **アクセシビリティテスト**: ユーザビリティ確認

## 🔄 継続的改善プロセス

### 月次レビュー項目

- [ ] 依存関係の更新確認
- [ ] セキュリティ脆弱性チェック
- [ ] パフォーマンスメトリクス確認
- [ ] ユーザーフィードバック反映
- [ ] 学習コンテンツの更新

### 四半期レビュー項目

- [ ] フレームワーク大型アップデート対応
- [ ] 新機能・ベストプラクティス取り込み
- [ ] ドキュメントの全面見直し
- [ ] 競合テンプレートとの比較検討

## 🚀 実装優先順位

### 短期（1ヶ月以内）

1. ✅ 基本ビルドパイプライン設定
2. ⏳ Jest + Testing Library セットアップ
3. ⏳ Prettier + Husky 導入

### 中期（3ヶ月以内）

1. ⏳ E2Eテスト環境構築
2. ⏳ パフォーマンス監視導入
3. ⏳ セキュリティ対策強化

### 長期（6ヶ月以内）

1. ⏳ 高度なCI/CDパイプライン
2. ⏳ 自動化されたリリース管理
3. ⏳ 包括的なモニタリング

この戦略により、学習テンプレートでありながらプロダクション品質のコードベースを維持し、学習者が段階的に高度な開発手法を習得できる環境を提供します。
