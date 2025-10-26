# Next.js Learning Template (next-tpl)

安定したNext.js学習環境を提供するテンプレートプロジェクト

## 🎯 学習サンプル

セットアップ後、以下のサンプルページで学習を開始できます：

- **メインページ**: `http://localhost:3000/` - テンプレート概要
- **学習サンプル**: `http://localhost:3000/example` - React/Next.js基礎学習ページ

学習サンプルページには以下が含まれています：
- React Hooks（useState, useEffect）の使用例
- TypeScript型定義の実践例
- TailwindCSSスタイリング
- イベントハンドリングと状態管理
- 非同期処理の実装

## 🚀 Quick Start

### 最簡単セットアップ
```bash
# テンプレートをクローン
git clone https://github.com/your-username/next-tpl.git my-next-project
cd my-next-project

# 自動セットアップ実行（シェル自動検出）
./setup

# 学習サンプルにアクセス
# ブラウザで http://localhost:3000/example を開く
```

### Manual Setup
```bash
# テンプレートをクローン
git clone https://github.com/your-username/next-tpl.git my-next-project
cd my-next-project

# Node.jsバージョン自動切り替え（nvmユーザー）
nvm use

# 依存関係インストール & 開発サーバー起動
npm install
npm run dev
```

### Docker版（完全環境固定）
```bash
git clone https://github.com/your-username/next-tpl.git my-next-project
cd my-next-project

# 開発環境をDockerで起動
make dev-docker
# または
npm run docker:dev
```

## 🔒 環境固定化

- **Node.js**: 22.11.0 (完全固定)
- **Next.js**: 16.0.0
- **React**: 19.2.0
- **Docker**: 完全環境隔離
- **依存関係**: package-lock.jsonで固定

## 📁 構成

```
next-tpl/
├── app/                 # Next.js App Router
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── docs/               # ドキュメンテーション
│   ├── development/    # 開発記録（開発者向け）
│   └── tpl/           # 使用ガイド（学習者向け）
├── public/            # 静的ファイル
├── tools/             # セットアップスクリプト
│   ├── setup.sh       # Bash版
│   └── setup.zsh      # Zsh版
├── .dockerignore      # Docker除外設定
├── .gitignore        # Git除外設定
├── .nvmrc            # Node.jsバージョン固定
├── docker-compose.yml # Docker Compose設定
├── Dockerfile*       # Docker設定
├── Makefile          # 開発タスク
├── package.json      # 依存関係固定
├── setup             # メインセットアップ（シェル自動選択）
└── tsconfig.json     # TypeScript設定
```

## 🐳 Docker戦略

このテンプレートは**Dockerイメージをレジストリにアップロードしません**：

- ✅ **学習効果**: ビルドプロセスも学習の一部
- ✅ **カスタマイズ自由**: 自由に変更・実験可能
- ✅ **最新性**: 常に最新ソースから構築
- ✅ **管理簡単**: GitHubソース管理のみ

## 📚 詳細ドキュメント

### 学習者向け
- [`docs/tpl/point01.md`](./docs/tpl/point01.md) - 包括的使用ガイド
- [`docs/tpl/point02.md`](./docs/tpl/point02.md) - バージョン固定戦略

### 開発者向け
- [`docs/development/README.md`](./docs/development/README.md) - 開発記録概要
- [`tools/README.md`](./tools/README.md) - セットアップツール詳細

### 利用可能なコマンド
```bash
# 基本コマンド
make help          # 全コマンド表示
make setup         # インタラクティブセットアップ
make dev           # ローカル開発サーバー
make dev-docker    # Docker開発サーバー
make clean         # 環境リセット

# クリーンアップコマンド
./tools/cleanup.zsh --dry-run  # 削除対象ファイル表示
./tools/cleanup.zsh --force    # 強制クリーンアップ実行
./tools/cleanup.zsh           # インタラクティブクリーンアップ
```

## 🧹 プロジェクトクリーンアップ

不要なファイルを自動削除する高機能スクリプトを提供：

### 削除対象
- **ビルド成果物**: `.next/`, `out/`, `build/`
- **一時ファイル**: `*.tmp`, `*.log`, `logs/`
- **OS生成ファイル**: `.DS_Store`, `Thumbs.db`
- **エディタファイル**: `*.swp`, `*.swo`, `.vscode/settings.json`
- **キャッシュファイル**: `.eslintcache`, `*.tsbuildinfo`

### 使用例
```bash
# 削除対象確認（安全）
./tools/cleanup.zsh --dry-run

# インタラクティブ削除
./tools/cleanup.zsh

# 確認なし削除（注意）
./tools/cleanup.zsh --force
```

## 🎯 使用目的

このテンプレートは、Next.jsの学習を継続的かつ安定的に行うための土台です：

- ✅ 環境差分による問題を排除
- ✅ アップデートの影響を回避
- ✅ どこでも同じ環境で学習継続
- ✅ チーム学習での環境統一

---

Created: 2025/10/26 | Updated for stable learning environment
