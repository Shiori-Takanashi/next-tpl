# Copilot作業記録02: Docker環境構築とバージョン固定

## 実装内容

### Node.jsバージョン固定

#### .nvmrcファイル作成
```bash
# /home/tani09/allprojects/next-tpl/.nvmrc
22.11.0
```

**目的**:
- nvmユーザーの自動バージョン切り替え
- チーム開発での統一Node.jsバージョン
- 明示的なバージョン指定

#### package.json engines設定
```json
{
  "engines": {
    "node": "22.11.0",
    "npm": ">=10.0.0"
  }
}
```

**効果**:
- npm installでのバージョンチェック
- CI/CDでのバージョン強制
- 開発環境の標準化

### Docker環境構築

#### 本番用Dockerfile
```dockerfile
FROM node:22.11.0-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

**特徴**:
- Alpine Linuxで軽量化
- マルチステージビルド対応
- 本番最適化

#### 開発用Dockerfile.dev
```dockerfile
FROM node:22.11.0-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci
EXPOSE 3000
CMD ["npm", "run", "dev"]
```

**特徴**:
- 開発依存関係を含む
- ホットリロード対応
- デバッグ環境最適化

#### Docker Compose設定
```yaml
version: '3.8'

services:
  next-tpl:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production

  next-tpl-dev:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3001:3000"
    volumes:
      - .:/app
      - /app/node_modules
      - /app/.next
    environment:
      - NODE_ENV=development
```

**利点**:
- 本番・開発環境の並行起動
- ボリュームマウントでホットリロード
- ポート分離で競合回避

#### .dockerignoreファイル
```ignore
node_modules
npm-debug.log*
.next
.env*.local
.vercel
.git
.gitignore
README.md
Dockerfile*
docker-compose*
coverage
.DS_Store
*.pem
```

**目的**:
- Dockerイメージサイズ削減
- ビルド時間短縮
- セキュリティ向上

### package.jsonスクリプト追加

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "eslint",
    "docker:dev": "docker-compose up next-tpl-dev",
    "docker:build": "docker build -t next-tpl .",
    "docker:run": "docker run -p 3000:3000 next-tpl"
  }
}
```

**追加されたスクリプト**:
- `docker:dev`: 開発環境起動
- `docker:build`: イメージビルド
- `docker:run`: コンテナ実行

## 検証と確認

### 動作確認手順
```bash
# ローカル環境
nvm use
npm install
npm run dev

# Docker環境
npm run docker:dev
```

### バージョン確認
```bash
node --version  # v22.11.0
npm --version   # 10.x.x
```

## 技術的な判断

### Dockerイメージアップロード戦略
**決定**: イメージをレジストリにアップロードしない

**理由**:
- 学習効果: ビルドプロセスも学習の一部
- カスタマイズ性: 自由な変更・実験が可能
- 管理簡素化: GitHubソース管理のみ
- 最新性: 常に最新ソースからビルド

### Alpine Linux採用理由
- **軽量**: ベースイメージサイズ削減
- **セキュリティ**: 最小限のパッケージ
- **互換性**: Node.js公式サポート

## 成果

### 環境固定化レベル
- ✅ Node.js 22.11.0 完全固定
- ✅ Docker環境での完全隔離
- ✅ 依存関係のlockファイル管理
- ✅ 本番・開発環境の分離

### 利用パターン確立
1. ローカル開発: `nvm use && npm install && npm run dev`
2. Docker開発: `npm run docker:dev`
3. 本番確認: `npm run docker:build && npm run docker:run`

---
**関連記録**:
- [01-project-overview.md](./01-project-overview.md) - プロジェクト概要と初期セットアップ
- [03-automation-tools.md](./03-automation-tools.md) - 自動化スクリプトと開発支援ツール
