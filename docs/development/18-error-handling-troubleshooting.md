# エラー処理とトラブルシューティング実装記録

## 概要

プロジェクト開発中に遭遇したエラーと解決方法の詳細記録

## TypeScriptエラー解決

### CSS Import型エラー

```typescript
// エラー内容
Cannot find module or type declarations for side-effect import of './globals.css'.
```

#### 原因分析

- TypeScriptがCSSファイルの型定義を認識できない
- Next.js 16でのTypeScript設定の変更
- モジュール解決の設定不足

#### 解決方法

```typescript
// globals.d.ts 作成
declare module "*.css" {
  const content: any;
  export default content;
}

declare module "*.module.css" {
  const classes: { readonly [key: string]: string };
  export default classes;
}
```

#### 設定変更

```json
// tsconfig.json
{
  "include": [
    "next-env.d.ts",
    "globals.d.ts", // 追加
    "**/*.ts",
    "**/*.tsx"
  ]
}
```

### Next.js 16 Viewport警告

```
⚠ Unsupported metadata viewport is configured in metadata export
```

#### 原因

Next.js 16でのmetadata API変更により、viewportは独立したexportが必要

#### 解決前

```typescript
export const metadata: Metadata = {
  viewport: "width=device-width, initial-scale=1",
};
```

#### 解決後

```typescript
export const metadata: Metadata = {
  // viewport削除
};

export const viewport = {
  width: "device-width",
  initialScale: 1,
};
```

## ビルドエラー解決

### Turbopack関連エラー

```bash
# エラー例
Failed to compile with Turbopack
```

#### 対処法

```bash
# .nextディレクトリクリア
rm -rf .next

# クリーンビルド
npm run build
```

### 依存関係エラー

```bash
# パッケージ競合エラー対処
npm ci  # package-lock.jsonから正確にインストール
```

## 開発サーバーエラー

### ポート使用中エラー

```bash
Error: listen EADDRINUSE: address already in use :::3000
```

#### 解決方法

```bash
# プロセス確認
lsof -ti:3000

# プロセス終了
kill -9 $(lsof -ti:3000)

# または別ポート使用
npm run dev -- --port 3001
```

### Docker関連エラー

```bash
# Docker daemon未起動
Cannot connect to the Docker daemon
```

#### 対処法

```bash
# Dockerサービス確認・起動
sudo systemctl start docker
# または
open -a Docker  # macOS
```

## ESLint設定エラー

### プラグイン未定義エラー

```
Could not find plugin "@typescript-eslint"
```

#### 解決方法

```javascript
// eslint.config.mjs - 修正前
import next from "eslint-config-next";

// 修正後 - TypeScript関連削除
import js from "@eslint/js";
import next from "eslint-config-next";

export default [
  js.configs.recommended,
  ...next,
  {
    rules: {
      "no-unused-vars": "warn", // TypeScript特有ルール削除
    },
  },
];
```

## TailwindCSS関連エラー

### PostCSS設定エラー

```
Error: PostCSS plugin @tailwindcss/postcss not found
```

#### 解決方法

```javascript
// postcss.config.mjs
const config = {
  plugins: {
    "@tailwindcss/postcss": {}, // 正しいプラグイン名
  },
};
```

### CSS変数認識エラー

```css
/* 解決前 */
@import "tailwindcss/base";
@import "tailwindcss/components";
@import "tailwindcss/utilities";

/* 解決後 */
@import "tailwindcss";
```

## フォント読み込みエラー

### Google Fonts読み込み失敗

```typescript
// 原因: サブセット指定ミス
const font = Noto_Sans_JP({
  subsets: ["japanese"], // 存在しないサブセット
});

// 解決
const font = Noto_Sans_JP({
  subsets: ["latin"], // 正しいサブセット
  display: "swap", // FOIT回避
});
```

## パフォーマンス問題

### 開発サーバー起動遅延

```bash
# 原因分析
- 大量のファイル監視
- 不要なディレクトリスキャン

# 解決方法
# .gitignore最適化
node_modules/
.next/
*.log
```

### ビルド時間長期化

```typescript
// next.config.ts最適化
const nextConfig: NextConfig = {
  experimental: {
    turbo: {
      // Turbopack最適化設定
    },
  },
  // 不要な機能無効化
  poweredByHeader: false,
  reactStrictMode: true,
};
```

## Docker環境問題

### コンテナ起動失敗

```dockerfile
# 原因: Node.jsバージョン不一致
FROM node:18-alpine  # 古いバージョン

# 解決
FROM node:22.11.0-alpine  # 固定バージョン
```

### ボリュームマウント問題

```yaml
# docker-compose.yml
volumes:
  - .:/app
  - /app/node_modules # node_modules除外
```

## Git関連問題

### LF/CRLF改行コード問題

```bash
# 設定
git config core.autocrlf false

# .gitattributes作成
* text=auto
*.sh text eol=lf
*.zsh text eol=lf
```

### 大容量ファイルコミット防止

```gitignore
# .gitignore強化
*.log
.next/
node_modules/
.DS_Store
```

## VS Code統合問題

### 拡張機能競合

```json
// settings.json
{
  "css.validate": false, // TailwindCSSとの競合回避
  "less.validate": false,
  "scss.validate": false
}
```

### TypeScript言語サーバー問題

```bash
# VS Code内でコマンド実行
# Ctrl+Shift+P → "TypeScript: Restart TS Server"
```

## トラブルシューティング手順

### 標準診断手順

```bash
# 1. 環境確認
node --version     # 22.11.0確認
npm --version      # パッケージマネージャー確認

# 2. キャッシュクリア
rm -rf .next
rm -rf node_modules
npm ci

# 3. 段階的確認
npm run type-check  # TypeScript確認
npm run lint       # ESLint確認
npm run build      # ビルド確認
npm run dev        # 開発サーバー確認
```

### Docker環境診断

```bash
# 1. Docker確認
docker --version
docker-compose --version

# 2. イメージ再構築
docker-compose down
docker-compose build --no-cache
docker-compose up
```

## 予防策

### 開発環境固定化

- Node.jsバージョン固定（.nvmrc）
- 依存関係固定（package-lock.json）
- Docker環境利用

### 定期メンテナンス

```bash
# 週次実行推奨
npm audit        # セキュリティ監査
npm outdated     # 依存関係確認
docker system prune  # Docker清掃
```

## 学習者向けエラー対応

### よくあるエラーパターン

1. **環境構築エラー**: 自動セットアップスクリプト使用
2. **バージョン不一致**: Docker環境推奨
3. **設定ファイルエラー**: テンプレート設定そのまま使用

### エラー報告テンプレート

```markdown
## エラー内容

- エラーメッセージ:
- 発生タイミング:
- 環境情報:

## 再現手順

1.
2.
3.

## 期待する動作

## 実際の動作
```

---

**作成**: 2025/10/27 **更新**: エラー解決時随時更新
**対象**: 開発者・学習者向けトラブルシューティング
