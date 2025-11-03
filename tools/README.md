# Tools Directory

このディレクトリには、Next.js学習テンプレートのセットアップと管理に使用するスクリプトが含まれています。

## 📁 ファイル構成

```
tools/
├── README.md          # このファイル
├── setup.sh           # Bash版セットアップスクリプト
├── setup.zsh          # Zsh版セットアップスクリプト
├── cleanup.zsh        # 不要ファイル削除スクリプト
├── git-helper.zsh     # Git操作支援ツール
├── dev-reset.zsh      # 開発環境リセットツール
├── deps-manager.zsh   # 依存関係管理ツール
├── deploy.zsh         # デプロイ支援ツール
└── dev-server.zsh     # 開発サーバー管理ツール
```

## 🚀 使用方法

### 自動シェル選択（推奨）

```bash
# ルートディレクトリから実行
./setup
```

このスクリプトは現在のシェル環境を自動検出し、適切なバージョンを実行します。

### 手動でシェル指定

```bash
# Bash版を明示的に実行
bash tools/setup.sh

# Zsh版を明示的に実行
zsh tools/setup.zsh

# クリーンアップスクリプト実行
./tools/cleanup.zsh --dry-run  # 削除対象確認
./tools/cleanup.zsh           # インタラクティブ削除
./tools/cleanup.zsh --force   # 強制削除

# Git操作支援
./tools/git-helper.zsh learn-start "component-practice"
./tools/git-helper.zsh learn-save "コンポーネント作成完了"
./tools/git-helper.zsh learn-reset

# 開発環境リセット
./tools/dev-reset.zsh --soft    # ビルド成果物のみ削除
./tools/dev-reset.zsh --full    # 完全リセット

# 依存関係管理
./tools/deps-manager.zsh check   # 依存関係チェック
./tools/deps-manager.zsh update  # パッケージ更新
./tools/deps-manager.zsh audit   # セキュリティ監査

# デプロイ支援
./tools/deploy.zsh build --clean  # クリーンビルド
./tools/deploy.zsh preview        # プレビュー
./tools/deploy.zsh check          # デプロイ前チェック

# 開発サーバー管理
./tools/dev-server.zsh start      # ローカルサーバー起動
./tools/dev-server.zsh docker-start # Dockerサーバー起動
./tools/dev-server.zsh health     # ヘルスチェック

# または簡単なラッパー経由
./cleanup --dry-run
```

## 🔧 スクリプトの特徴

### setup.sh (Bash版)

- **対象**: Bash 4.0以上
- **機能**: 基本的なセットアップ機能
- **互換性**: 最大限の互換性を重視

### setup.zsh (Zsh版)

- **対象**: Zsh 5.0以上
- **機能**: Zsh固有の機能を活用
- **特徴**:
  - `vared`コマンドでより良い入力体験
  - `setopt ERR_EXIT`でより厳密なエラーハンドリング
  - nvmの設定自動読み込み

### cleanup.zsh (クリーンアップ)

- **対象**: Zsh 5.0以上
- **機能**: 不要ファイルの自動削除
- **特徴**:
  - ビルド成果物、一時ファイル、キャッシュの削除
  - Dry-runモードで事前確認可能
  - インタラクティブ確認で安全性確保
  - ファイルサイズ表示と統計情報
  - 保護ファイル機能で重要ファイルを誤削除防止

### git-helper.zsh (Git操作支援)

- **対象**: Zsh 5.0以上
- **機能**: 学習者向けGitワークフロー自動化
- **特徴**:
  - 学習ブランチの作成・管理・削除
  - 学習内容の保存とリセット
  - クイックコミット機能
  - 詳細なステータス表示
  - リモート同期とブランチクリーンアップ

### dev-reset.zsh (開発環境リセット)

- **対象**: Zsh 5.0以上
- **機能**: 開発環境の初期化・リセット
- **特徴**:
  - ソフト/フル/カスタムリセットモード
  - カテゴリ別ファイル削除（キャッシュ、ビルド、依存関係等）
  - インタラクティブモードで安全な操作
  - 環境復旧機能で自動再セットアップ

### deps-manager.zsh (依存関係管理)

- **対象**: Zsh 5.0以上
- **機能**: パッケージ管理・セキュリティ監査
- **特徴**:
  - 古いパッケージの検出と更新
  - セキュリティ脆弱性の監査と修正
  - 依存関係の詳細分析とレポート生成
  - バックアップ・復元機能で安全な更新

### deploy.zsh (デプロイ支援)

- **対象**: Zsh 5.0以上
- **機能**: ビルド・デプロイ自動化
- **特徴**:
  - 本番ビルドとプレビュー機能
  - Docker統合でコンテナベースデプロイ
  - デプロイ前チェックで品質保証
  - Vercel/Netlify等のプラットフォーム対応
  - バンドル分析とパフォーマンス測定

### dev-server.zsh (開発サーバー管理)

- **対象**: Zsh 5.0以上
- **機能**: ローカル・Docker開発環境管理
- **特徴**:
  - ローカル/Docker両対応のサーバー管理
  - バックグラウンド起動とプロセス管理
  - ヘルスチェックとリアルタイム監視
  - ポート管理と自動衝突解決
  - ログ表示とブラウザ連携

## 🛠️ 開発者向け情報

### スクリプト追加ガイドライン

1. **命名規則**: `<機能名>.<シェル>`形式
2. **実行権限**: `chmod +x`で実行権限を付与
3. **shebang**: 適切なシェルを指定
4. **エラーハンドリング**: 適切なエラー処理を実装

### 新しいスクリプト例

```bash
# tools/deploy.sh
#!/bin/bash
set -e
echo "デプロイスクリプト（Bash版）"

# tools/deploy.zsh
#!/bin/zsh
setopt ERR_EXIT
echo "デプロイスクリプト（Zsh版）"
```

## 🔍 トラブルシューティング

### 実行権限がない場合

```bash
chmod +x tools/setup.sh tools/setup.zsh
```

### シェルが見つからない場合

```bash
# 利用可能なシェルを確認
cat /etc/shells

# シェルのパスを確認
which bash
which zsh
```

### 未対応シェルの場合

bash版のスクリプトを直接実行してください：

```bash
bash tools/setup.sh
```

---

**関連ドキュメント**:

- [../docs/tpl/point01.md](../docs/tpl/point01.md) - 使用ガイド
- [../docs/development/03-automation-tools.md](../docs/development/03-automation-tools.md) - スクリプト実装記録
- [../docs/development/06-tools-restructure.md](../docs/development/06-tools-restructure.md) - ツール構造改善記録
