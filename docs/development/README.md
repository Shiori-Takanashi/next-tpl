# 開発者向けドキュメント

このディレクトリには、Next.js学習テンプレートの開発・保守に関する完全なドキュメントが格納されています。

## 📋 ドキュメント一覧

### プロジェクト基盤
- [01-project-overview.md](./01-project-overview.md) - プロジェクトの概要と目的
- [02-docker-environment.md](./02-docker-environment.md) - Docker環境の設計と実装
- [03-automation-tools.md](./03-automation-tools.md) - セットアップ自動化とツール

### ドキュメント戦略
- [04-documentation-strategy.md](./04-documentation-strategy.md) - ドキュメント構成の方針
- [05-final-verification.md](./05-final-verification.md) - 最終検証とテスト
- [06-tools-restructure.md](./06-tools-restructure.md) - ツール構成の再編成

### プロジェクト最適化
- [07-project-optimization.md](./07-project-optimization.md) - プロジェクト全体の最適化記録
- [08-testing-strategy.md](./08-testing-strategy.md) - テストとCI/CD戦略
- [09-security-practices.md](./09-security-practices.md) - セキュリティとベストプラクティス
- [10-performance-optimization.md](./10-performance-optimization.md) - パフォーマンス最適化ガイド

### UI/UX・技術詳細
- [11-ui-design-system.md](./11-ui-design-system.md) - デザインシステム設計記録
- [12-japanese-optimization.md](./12-japanese-optimization.md) - 日本語最適化実装記録
- [13-tailwindcss-v4.md](./13-tailwindcss-v4.md) - TailwindCSS v4 実装記録
- [14-vscode-integration.md](./14-vscode-integration.md) - VS Code統合開発環境構築記録

### 自動化・最新技術
- [15-automation-scripts.md](./15-automation-scripts.md) - 自動化スクリプト詳細実装記録
- [16-nextjs-16-react-19.md](./16-nextjs-16-react-19.md) - Next.js 16.0.0 + React 19.2.0 実装記録
- [17-project-completion-analysis.md](./17-project-completion-analysis.md) - プロジェクト完成度と学習効果分析

### 実践・運用
- [18-error-handling-troubleshooting.md](./18-error-handling-troubleshooting.md) - エラー処理とトラブルシューティング実装記録
- [19-learning-curriculum.md](./19-learning-curriculum.md) - 学習カリキュラム設計と実装戦略
- [20-production-deployment.md](./20-production-deployment.md) - プロダクション環境デプロイ戦略

### コンポーネント・リファクタリング
- [21-component-system-design.md](./21-component-system-design.md) - コンポーネントシステム設計と実装記録
- [22-ui-ux-refactoring.md](./22-ui-ux-refactoring.md) - UI/UXリファクタリング実装記録

### ツールセット・開発支援
- [23-tools-extension.md](./23-tools-extension.md) - 包括的開発ツールセット拡張実装記録

## 🎯 開発ガイド

### テンプレートのカスタマイズ

1. **基本設定の変更**
   ```bash
   # package.jsonのメタデータ更新
   - name, description, author
   - repository URL
   - keywords
   ```

2. **Docker設定の調整**
   ```bash
   # Dockerfileの最適化
   - Node.jsバージョン変更
   - 依存関係の調整
   - マルチステージビルドの変更
   ```

3. **自動化スクリプトの拡張**
   ```bash
   # tools/ディレクトリでの作業
   - setup.sh / setup.zsh の機能追加
   - 新しいシェル対応
   - 検証ロジックの改善
   ```

### テスト戦略

#### 手動テスト
```bash
# 基本動作確認
make setup          # セットアップ確認
make dev            # ローカル開発
make dev-docker     # Docker開発
make build          # ビルド確認
make lint           # コード品質確認
```

#### 環境テスト
```bash
# 異なる環境での検証
- 新規環境でのsetup実行
- 既存プロジェクトでの動作確認
- シェル別の動作確認（bash/zsh）
```

### 保守・更新の方針

#### 依存関係の更新
```bash
# セマンティックバージョニングに従った更新
- Next.js: メジャーバージョンは慎重に
- React: Next.jsと互換性を確認
- TypeScript: 型定義の変更を確認
```

#### ドキュメントの更新
```bash
# 変更に伴うドキュメント更新
1. 技術変更 → 該当ドキュメントを更新
2. 新機能追加 → README.mdとdocsを更新
3. 破壊的変更 → 移行ガイドを作成
```

## 🔧 開発環境セットアップ

### 必要な環境
- Node.js 22.11.0+
- Docker & Docker Compose
- Git
- bash または zsh

### 開発開始手順
```bash
# 1. リポジトリのクローン
git clone <repository-url>
cd next-tpl

# 2. 開発環境セットアップ
./setup

# 3. 開発モード起動
make dev
```

### トラブルシューティング

#### よくある問題
1. **Node.jsバージョン不一致**
   - .nvmrcを確認
   - nvm use で正しいバージョンに切り替え

2. **Docker関連エラー**
   - Docker Desktopが起動しているか確認
   - docker-compose versionで動作確認

3. **ポート競合**
   - 3000番ポートが使用中の場合
   - docker-compose.ymlでポート変更

## 📝 変更履歴の記録

重要な変更は以下に記録してください：

### [0.1.0] - 初期リリース
- 基本的なNext.jsテンプレート
- Docker環境
- 自動化スクリプト
- ドキュメント体系

### 今後の予定
- [ ] テストフレームワークの統合
- [ ] CI/CDパイプラインの追加
- [ ] より多くの学習リソースの組み込み
- [ ] プラグイン機能の検討

## 🤝 コントリビューション

### 変更提案の流れ
1. Issueでの議論
2. ブランチ作成（feature/xxx）
3. 実装・テスト
4. ドキュメント更新
5. プルリクエスト

### コードレビューのポイント
- 学習者にとっての理解しやすさ
- ドキュメントの整合性
- 異なる環境での動作確認
- セキュリティとベストプラクティス

## 🔗 関連ドキュメント

### ユーザー向けドキュメント
- [../tpl/point01.md](../tpl/point01.md) - 使用ガイド（包括的）
- [../tpl/point02.md](../tpl/point02.md) - バージョン戦略（詳細検討）

### プロジェクト概要
- [../../README.md](../../README.md) - プロジェクトメインドキュメント
- [../../tools/README.md](../../tools/README.md) - セットアップツール説明

### ユーザー向けドキュメント（User Documentation）
```
docs/tpl/
├── point01.md                  # 使用ガイド（包括的）
└── point02.md                  # バージョン戦略（詳細検討）
```

## 🎯 開発記録の目的

### 1. 透明性の確保
- 実装過程の完全な記録
- 意思決定の理由と根拠の明示
- 技術的選択肢の比較検討

### 2. 学習価値の提供
- 実践的な開発プロセスの体験
- 問題解決のアプローチ方法
- ベストプラクティスの実装例

### 3. 保守・拡張の支援
- 将来の改修時の参考資料
- 新機能追加時の設計指針
- トラブルシューティングの手がかり

## 📚 読み進め方

### 順次読解（推奨）
1. **01-project-overview.md**: 全体像の把握
2. **02-docker-environment.md**: 環境固定化の理解
3. **03-automation-tools.md**: 自動化の実装
4. **04-documentation-strategy.md**: ドキュメント戦略
5. **05-final-verification.md**: 完成品の評価
6. **06-tools-restructure.md**: 最新の改善

### 目的別読解
- **Docker理解**: 02-docker-environment.md
- **シェル対応**: 03-automation-tools.md + 06-tools-restructure.md
- **バージョン戦略**: 04-documentation-strategy.md + ../tpl/point02.md
- **全体設計**: 01-project-overview.md + 05-final-verification.md

## 🔗 関連ドキュメント

### 外部参照
- [../tpl/point01.md](../tpl/point01.md) - ユーザー向け使用ガイド
- [../tpl/point02.md](../tpl/point02.md) - バージョン固定戦略詳細
- [../../tools/README.md](../../tools/README.md) - セットアップツール説明
- [../../README.md](../../README.md) - プロジェクト概要

### 開発者向けリソース
- **実装コード**: ルートディレクトリの各設定ファイル
- **Docker設定**: Dockerfile, docker-compose.yml
- **自動化スクリプト**: tools/ディレクトリ
- **ビルド設定**: package.json, Makefile

## 🔄 更新履歴

| 日付 | 更新内容 |
|------|----------|
| 2025-10-26 | 初回実装完了、全6記録作成 |
| 2025-10-26 | ファイル構造改善、development/ディレクトリ化 |

---

**注意**: これらの記録は実装時点（2025年10月26日）の内容です。将来の更新により、一部の技術的詳細が変更される可能性があります。
