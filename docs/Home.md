# Next.js 学習テンプレート (next-tpl) - Wiki

🎌 **日本語最適化済み** | モダンで美しいデザイン | 安定した学習環境

最新のNext.js + React + TypeScript + TailwindCSS
v4を使用した、日本語環境に最適化された学習テンプレートです。

## 📚 ドキュメント構成

このWikiには、プロジェクトの開発記録と技術詳細が含まれています。

### 🎯 クイックナビゲーション

| カテゴリ              | ドキュメント                                                   | 説明                               |
| --------------------- | -------------------------------------------------------------- | ---------------------------------- |
| **🚀 基盤**           | [01-プロジェクト概要](./01-project-overview)                   | プロジェクトの全体像と設計方針     |
|                       | [02-Docker環境](./02-docker-environment)                       | Docker環境の設計と実装             |
|                       | [03-自動化ツール](./03-automation-tools)                       | セットアップ自動化                 |
| **📖 戦略**           | [04-ドキュメント戦略](./04-documentation-strategy)             | ドキュメント構成の方針             |
|                       | [05-最終検証](./05-final-verification)                         | 品質検証とテスト                   |
|                       | [06-ツール再編成](./06-tools-restructure)                      | ツール構成の最適化                 |
| **⚡ 最適化**         | [07-プロジェクト最適化](./07-project-optimization)             | 全体最適化記録                     |
|                       | [08-テスト戦略](./08-testing-strategy)                         | テストとCI/CD                      |
|                       | [09-セキュリティ](./09-security-practices)                     | セキュリティ実践                   |
|                       | [10-パフォーマンス](./10-performance-optimization)             | パフォーマンス最適化               |
| **🎨 UI/UX**          | [11-デザインシステム](./11-ui-design-system)                   | デザインシステム設計               |
|                       | [12-日本語最適化](./12-japanese-optimization)                  | 日本語環境最適化                   |
|                       | [13-TailwindCSS v4](./13-tailwindcss-v4)                       | TailwindCSS v4実装                 |
|                       | [14-VSCode統合](./14-vscode-integration)                       | 開発環境構築                       |
| **🔧 技術詳細**       | [15-自動化スクリプト](./15-automation-scripts)                 | スクリプト実装詳細                 |
|                       | [16-Next.js 16 + React 19](./16-nextjs-16-react-19)            | 最新版実装記録                     |
|                       | [17-完成度分析](./17-project-completion-analysis)              | プロジェクト完成度評価             |
| **🛠️ 実践**           | [18-エラーハンドリング](./18-error-handling-troubleshooting)   | エラー処理とトラブルシューティング |
|                       | [19-学習カリキュラム](./19-learning-curriculum)                | 学習カリキュラム設計               |
|                       | [20-本番デプロイ](./20-production-deployment)                  | デプロイ戦略                       |
| **🧩 コンポーネント** | [21-コンポーネント設計](./21-component-system-design)          | コンポーネントシステム             |
|                       | [22-UI/UXリファクタリング](./22-ui-ux-refactoring)             | UI/UX改善記録                      |
| **⚙️ 開発支援**       | [23-ツール拡張](./23-tools-extension)                          | 開発ツールセット                   |
|                       | [24-CIワークフロー](./24-ci-workflow-modularization)           | GitHub Actionsモジュール化         |
|                       | [25-開発標準](./25-development-standards)                      | 開発環境標準化                     |
| **📦 管理**           | [26-Wiki移行戦略](./26-github-wiki-migration-strategy)         | GitHub Wiki自動化                  |
|                       | [27-ワークフロー分離](./27-github-actions-workflow-separation) | CI/CD責任分離設計                  |
| **✅ 品質保証**       | [28-Git Hooks自動化](./28-git-hooks-automation)                | Husky + lint-staged                |
|                       | [29-CIワークフロー統合](./29-ci-workflow-consolidation)        | ワークフロー最適化                 |

## 🚀 Quick Start

### 最簡単セットアップ

```bash
# テンプレートをクローン
git clone https://github.com/Shiori-Takanashi/next-tpl.git my-next-project
cd my-next-project

# 自動セットアップ実行
make setup

# 開発サーバー起動
make dev
```

詳細は [03-自動化ツール](./03-automation-tools) を参照してください。

## ✨ 主な特徴

### 🎨 モダンデザイン

- **グラスモーフィズム効果**: 美しい半透明レイヤーデザイン
- **スムーズアニメーション**: fade-in、slide-inエフェクト
- **レスポンシブ対応**: モバイルから4Kまで完全対応
- **ダークモード対応**: システム設定に自動追従

詳細は [11-デザインシステム](./11-ui-design-system) を参照してください。

### 🇯🇵 日本語最適化

- **日本語フォント**: Noto Sans JP（Web最適化済み）
- **プログラミング用フォント**: JetBrains Mono（日本語コメント対応）
- **日本語タイポグラフィ**: 適切な行間・字間設定
- **ロケール設定**: 完全日本語環境

詳細は [12-日本語最適化](./12-japanese-optimization) を参照してください。

### 🚀 最新技術スタック

- **Next.js 16.0.0**: App Router + React Server Components
- **React 19.2.0**: 最新機能フル活用
- **TailwindCSS v4**: カスタムデザインシステム
- **TypeScript**: 型安全性確保

詳細は [16-Next.js 16 + React 19](./16-nextjs-16-react-19) を参照してください。

## 🔒 環境固定化

- **Node.js**: 22.11.0 (完全固定)
- **Next.js**: 16.0.0
- **React**: 19.2.0
- **Docker**: 完全環境隔離
- **依存関係**: package-lock.jsonで固定

詳細は [02-Docker環境](./02-docker-environment) を参照してください。

## 🛠️ 開発ツールセット

学習から本番デプロイまでをカバーする包括的な開発支援ツール群を提供しています：

- **git-helper.zsh**: 学習ブランチ管理
- **dev-server.zsh**: 開発サーバー管理・監視
- **deps-manager.zsh**: 依存関係管理・セキュリティ監査
- **deploy.zsh**: デプロイ前品質チェック
- **cleanup.zsh**: プロジェクトクリーンアップ
- **migrate-to-wiki.zsh**: GitHub Wiki自動移行

詳細は [23-ツール拡張](./23-tools-extension) を参照してください。

## 📖 推奨読解順序

### 初めての方

1. [01-プロジェクト概要](./01-project-overview) - 全体像の把握
2. [03-自動化ツール](./03-automation-tools) - セットアップ方法
3. [11-デザインシステム](./11-ui-design-system) - デザインの理解
4. [23-ツール拡張](./23-tools-extension) - 開発ツールの使い方

### 技術詳細を知りたい方

1. [02-Docker環境](./02-docker-environment) - 環境構築の理解
2. [16-Next.js 16 + React 19](./16-nextjs-16-react-19) - 最新技術スタック
3. [13-TailwindCSS v4](./13-tailwindcss-v4) - スタイリング実装
4. [24-CIワークフロー](./24-ci-workflow-modularization) - CI/CD構成

### 開発者向け

1. [04-ドキュメント戦略](./04-documentation-strategy) - ドキュメント方針
2. [08-テスト戦略](./08-testing-strategy) - テスト設計
3. [09-セキュリティ](./09-security-practices) - セキュリティ実践
4. [25-開発標準](./25-development-standards) - 開発標準化

## 🔗 外部リンク

- [GitHubリポジトリ](https://github.com/Shiori-Takanashi/next-tpl)
- [Next.js公式ドキュメント](https://nextjs.org/docs)
- [React公式ドキュメント](https://react.dev/)
- [TailwindCSS公式ドキュメント](https://tailwindcss.com/)

## 📝 更新履歴

| 日付 | 更新内容 | |------|---------|| | 2025-11-22 |
28-29番ドキュメント追加（Git Hooks・CIワークフロー最適化） | | 2025-11-22 |
GitHub Wiki用ホームページ作成 | | 2025-11-21 | README.md最新化 | | 2025-11-05 |
Wiki移行戦略実装 | | 2025-11-04 | CI/CD標準化・環境設定統一 | | 2025-10-26
| プロジェクト初期リリース |

---

**Created**: 2025/10/26 | **Updated**: 2025/11/22 | 安定した学習環境を提供
