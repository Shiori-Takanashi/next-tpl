# Next.js 学習テンプレート (next-tpl) 使用ガイド

## 概要

`next-tpl`は、Next.jsを安定的に学習するための土台として設計されたテンプレートプロジェクトです。GitHubからクローンして、Dockerで環境を固定化することで、アップデートがあっても常に同じ環境で学習を継続できます。

## 環境固定化

### Node.jsバージョン固定
- **Node.js**: 22.11.0 (LTS)
- **npm**: 10.0.0以上
- **.nvmrc**: Node.jsバージョン自動切り替え対応
- **engines**: package.jsonでバージョン強制

### Docker対応
- **本番用**: Dockerfile
- **開発用**: Dockerfile.dev
- **Docker Compose**: 簡単起動設定
- **バージョン固定**: すべての依存関係を完全固定

### Dockerイメージ戦略
このテンプレートでは、**Dockerイメージをレジストリにアップロードしません**。理由：

#### ✅ ソースベース配布の利点
- **学習効果**: Dockerビルドプロセスも学習の一部
- **カスタマイズ自由**: 学習者が自由に変更可能
- **最新性保持**: 常に最新のソースから構築
- **管理簡単**: GitHubのソースコード管理のみ

#### 🔄 代替案（必要に応じて）
Docker Hubへのアップロードが必要な場合：
```bash
# イメージをビルド
docker build -t your-username/next-tpl:latest .

# Docker Hubにプッシュ
docker push your-username/next-tpl:latest

# 使用時
docker pull your-username/next-tpl:latest
docker run -p 3000:3000 your-username/next-tpl:latest
```

## クイックスタート

### 方法1: 自動セットアップ（最推奨）
```bash
# テンプレートをクローン
git clone https://github.com/your-username/next-tpl.git my-next-project
cd my-next-project

# インタラクティブセットアップ実行（シェル自動検出）
./setup

# または Makefileを使用
make setup

# 手動でシェルを指定する場合
bash tools/setup.sh    # Bash版
zsh tools/setup.zsh     # Zsh版
```

### 方法2: GitHubからクローン（手動）
```bash
# テンプレートをクローン
git clone https://github.com/your-username/next-tpl.git my-next-project
cd my-next-project

# Node.jsバージョンを自動切り替え（nvmを使用している場合）
nvm use

# 依存関係をインストール
npm install
# または
make install

# 開発サーバー起動
npm run dev
# または
make dev
```

### 方法3: Dockerで完全環境固定
```bash
# テンプレートをクローン
git clone https://github.com/your-username/next-tpl.git my-next-project
cd my-next-project

# 開発環境をDockerで起動
npm run docker:dev
# または
make dev-docker

# バックグラウンドで起動
make dev-docker-bg
```

### 方法4: 本番環境Docker
```bash
# Dockerイメージをビルド
npm run docker:build
# または
make build-docker-prod

# コンテナを起動
npm run docker:run
```

## プロジェクト構成

### 技術スタック
- **フレームワーク**: Next.js 16.0.0 (App Router)
- **ランタイム**: React 19.2.0
- **言語**: TypeScript 5.x
- **スタイリング**: TailwindCSS 4.x
- **リンター**: ESLint 9.x
- **フォント**: Geist Sans & Geist Mono

### ディレクトリ構造
```
next-tpl/
├── app/                    # App Router用ディレクトリ
│   ├── globals.css        # グローバルスタイル
│   ├── layout.tsx         # ルートレイアウト
│   └── page.tsx          # ホームページ
├── docs/                  # ドキュメンテーション
│   └── tpl/              # テンプレート関連ドキュメント
├── public/               # 静的ファイル
├── .dockerignore         # Docker除外ファイル
├── .gitignore           # Git除外ファイル
├── .nvmrc              # Node.jsバージョン固定
├── docker-compose.yml   # Docker Compose設定
├── Dockerfile          # 本番用Dockerファイル
├── Dockerfile.dev      # 開発用Dockerファイル
├── eslint.config.mjs    # ESLint設定
├── Makefile            # 開発用タスクランナー
├── next.config.ts       # Next.js設定
├── package.json         # 依存関係とスクリプト（バージョン固定）
├── postcss.config.mjs   # PostCSS設定
├── setup               # メインセットアップ（シェル自動選択）
├── tools/              # セットアップスクリプト集
│   ├── README.md       # ツール説明
│   ├── setup.sh        # Bash版セットアップ
│   └── setup.zsh       # Zsh版セットアップ
└── tsconfig.json        # TypeScript設定
```

## 環境固定化の利点

### 1. 完全な再現性
- **Node.js 22.11.0固定**: `.nvmrc`とpackage.jsonのenginesで固定
- **依存関係固定**: package-lock.jsonで完全固定
- **Docker環境**: OS、ランタイム、依存関係をすべて固定

### 2. 学習の継続性
- **アップデート影響なし**: 将来のパッケージ更新の影響を受けない
- **環境差分なし**: どのマシンでも同じ環境で学習可能
- **バックアップ機能**: GitHubから常に同じ状態を復元可能

### 3. チーム学習対応
- **統一環境**: チームメンバー全員が同じ環境
- **トラブル共有**: 同じ環境なので問題解決が容易
- **知識蓄積**: 学習内容をブランチで管理可能

## 使用パターン

### パターン1: 個人学習（推奨）
```bash
# 新しい学習プロジェクトを開始
git clone https://github.com/your-username/next-tpl.git learn-nextjs-routing
cd learn-nextjs-routing
git checkout -b feature/routing-practice
npm install
npm run dev
```

### パターン2: Docker学習
```bash
# 完全隔離環境で学習
git clone https://github.com/your-username/next-tpl.git docker-next-practice
cd docker-next-practice
docker-compose up next-tpl-dev
# ブラウザで http://localhost:3001 にアクセス
```

### パターン3: 複数バージョン比較
```bash
# 複数のプロジェクトで異なる機能を試す
git clone https://github.com/your-username/next-tpl.git project-a
git clone https://github.com/your-username/next-tpl.git project-b
git clone https://github.com/your-username/next-tpl.git project-c

# 各プロジェクトで異なる機能を実装して比較
```

### 2. 開発の流れ
1. **新機能の実装**: `app/`ディレクトリ内でページやコンポーネントを作成
2. **スタイリング**: TailwindCSSクラスを使用してデザイン
3. **型定義**: TypeScriptで型安全性を確保
4. **リンティング**: `npm run lint`でコード品質をチェック
5. **ビルド**: `npm run build`で本番環境用にビルド

### 3. 学習のポイント

#### App Routerの活用
- `app/`ディレクトリベースのルーティング
- `layout.tsx`でレイアウトの共通化
- `page.tsx`で各ページの実装

#### TypeScriptベストプラクティス
- コンポーネントの型定義
- Propsの型安全性
- Next.jsの型サポート活用

#### TailwindCSSの効率的な使用
- ユーティリティファーストのアプローチ
- レスポンシブデザインの実装
- ダークモード対応

## 学習の進め方

### Phase 1: 基礎理解
1. `app/page.tsx`を編集してNext.jsの基本を理解
2. 新しいページを`app/about/page.tsx`などで作成
3. コンポーネントの作成と再利用

### Phase 2: 機能拡張
1. APIルートの実装 (`app/api/`)
2. データフェッチング (Server Components, Client Components)
3. 状態管理の実装

### Phase 3: 高度な機能
1. 認証システムの実装
2. データベース連携
3. デプロイメント (Vercel, その他)

## ファイル変更時の注意点

### 重要なファイル
- `package.json`: 依存関係の管理、新しいパッケージ追加時は要確認
- `next.config.ts`: Next.js設定、機能追加時に設定が必要な場合あり
- `tsconfig.json`: TypeScript設定、コンパイルオプションの調整
- `eslint.config.mjs`: コーディング規約、チーム開発時は統一必須

### ベストプラクティス
1. **テンプレート保護**:
   ```bash
   # mainブランチは常に元の状態を保持
   git checkout main
   git pull origin main

   # 学習用ブランチで作業
   git checkout -b learn/feature-name
   ```

2. **Docker環境の活用**:
   ```bash
   # 開発環境の起動
   docker-compose up next-tpl-dev

   # バックグラウンド起動
   docker-compose up -d next-tpl-dev

   # 停止
   docker-compose down
   ```

3. **環境リセット**:
   ```bash
   # ローカル環境のリセット
   rm -rf node_modules package-lock.json .next
   npm install

   # Docker環境のリセット
   docker-compose down
   docker system prune -f
   docker-compose up --build next-tpl-dev
   ```

## トラブルシューティング

### 環境関連の問題
1. **Node.jsバージョン不一致**:
   ```bash
   # nvmを使用してバージョンを切り替え
   nvm install 22.11.0
   nvm use 22.11.0

   # または.nvmrcを使用
   nvm use
   ```

2. **Docker関連エラー**:
   ```bash
   # Dockerイメージの再ビルド
   docker-compose build --no-cache next-tpl-dev

   # Docker環境のクリーンアップ
   docker system prune -a
   ```

3. **依存関係の問題**:
   ```bash
   # ローカル環境
   rm -rf node_modules package-lock.json
   npm install

   # Docker環境
   docker-compose down
   docker-compose up --build
   ```

### GitHubアップロード準備
```bash
# GitHubリポジトリを作成後
git remote add origin https://github.com/your-username/next-tpl.git
git branch -M main
git push -u origin main

# タグ付けして安定版を管理
git tag -a v1.0.0 -m "Initial stable template"
git push origin v1.0.0
```

## まとめ

このテンプレートは、GitHubとDockerを活用してNext.jsの学習環境を完全に固定化します。主な特徴：

### 🔒 環境固定化
- Node.js 22.11.0で完全固定
- Docker環境でOS/ランタイム固定
- package-lock.jsonで依存関係固定

### 🚀 簡単開始
- `git clone`で即座に開始
- `npm run docker:dev`でDocker環境起動
- 設定不要で学習に集中

### 🔄 再現性
- どのマシンでも同じ環境
- アップデートの影響なし
- チーム学習に最適

### 📚 学習継続
- ブランチで学習内容を管理
- mainブランチで初期状態を保持
- 複数プロジェクトで並行学習可能

### 🔗 関連ドキュメント
- [point02.md](./point02.md) - package.jsonバージョン固定戦略の詳細検討
- [../development/README.md](../development/README.md) - 開発記録・実装過程の詳細

このテンプレートを使用することで、環境構築に時間を取られることなく、Next.jsの学習に専念できます。GitHubにプッシュして、いつでもどこでも同じ環境で学習を継続してください。
