# Next.js Learning Template (next-tpl)

安定したNext.js学習環境を提供するテンプレートプロジェクト

## 🚀 Quick Start

### 最簡単セットアップ
```bash
# テンプレートをクローン
git clone https://github.com/your-username/next-tpl.git my-next-project
cd my-next-project

# 自動セットアップ実行
./setup.sh
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
├── docs/tpl/           # 使用ガイド
├── Dockerfile*         # Docker設定
├── Makefile           # 開発タスク
├── setup.sh           # 自動セットアップ
├── .nvmrc             # Node.jsバージョン固定
└── package.json       # 依存関係固定
```

## 🐳 Docker戦略

このテンプレートは**Dockerイメージをレジストリにアップロードしません**：

- ✅ **学習効果**: ビルドプロセスも学習の一部
- ✅ **カスタマイズ自由**: 自由に変更・実験可能
- ✅ **最新性**: 常に最新ソースから構築
- ✅ **管理簡単**: GitHubソース管理のみ

## 📚 詳細ドキュメント

完全な使用方法は [`docs/tpl/point01.md`](./docs/tpl/point01.md) を参照してください。

## 🎯 使用目的

このテンプレートは、Next.jsの学習を継続的かつ安定的に行うための土台です：

- ✅ 環境差分による問題を排除
- ✅ アップデートの影響を回避
- ✅ どこでも同じ環境で学習継続
- ✅ チーム学習での環境統一

---

Created: 2025/10/26 | Updated for stable learning environment
