# Copilot作業記録03: 自動化スクリプトと開発支援ツール

## ツール構造の再設計（追加実装）

### tools/ディレクトリの作成

#### 設計思想
- **集約化**: セットアップ関連スクリプトの集中管理
- **シェル対応**: Bash/Zsh両対応でユーザー環境に最適化
- **保守性**: 機能別ファイル分割で保守しやすい構造

#### ディレクトリ構成
```
tools/
├── README.md      # ツールの説明とガイド
├── setup.sh       # Bash版セットアップスクリプト
└── setup.zsh      # Zsh版セットアップスクリプト
```

### メインセットアップスクリプト

#### setup（シェル自動選択）
```bash
#!/bin/bash
CURRENT_SHELL=$(basename "$SHELL")

case "$CURRENT_SHELL" in
    "zsh")
        exec zsh tools/setup.zsh
        ;;
    "bash")
        exec bash tools/setup.sh
        ;;
    *)
        exec bash tools/setup.sh
        ;;
esac
```

**特徴**:
- 現在のシェル環境を自動検出
- 適切なバージョンを自動選択・実行
- 未対応シェルではbashにフォールバック

## 自動セットアップスクリプト実装

### setup.shの作成

#### 機能概要
- Node.jsバージョンの自動確認
- Dockerの利用可否判定
- インタラクティブなセットアップ選択
- 環境に応じた最適化提案

#### スクリプト構造
```bash
#!/bin/bash
set -e

echo "🚀 Next.js学習テンプレートのセットアップを開始します..."

# Node.jsバージョンチェック
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "📋 現在のNode.jsバージョン: $NODE_VERSION"

    if [[ "$NODE_VERSION" != "v22.11.0" ]]; then
        echo "⚠️  推奨Node.jsバージョン: v22.11.0"

        if command -v nvm &> /dev/null; then
            echo "🔄 nvmを使用してNode.jsバージョンを切り替えます..."
            nvm use
        fi
    fi
fi

# セットアップオプション選択
echo "セットアップ方法を選択してください:"
echo "1) ローカル環境（npm install）"
echo "2) Docker開発環境"
echo "3) 両方セットアップ"
```

#### セットアップパターン
1. **ローカル環境**: npm install実行
2. **Docker環境**: docker-compose build実行
3. **両方**: 順次実行と選択肢提示

### setup.zsh（Zsh版）の実装

#### Zsh固有の機能活用
```zsh
#!/bin/zsh
setopt ERR_EXIT

# varedコマンドでより良い入力体験
vared -p "選択 (1-3): " -c choice

# nvm設定の自動読み込み
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    source "$HOME/.nvm/nvm.sh"
fi
```

#### Bash版との差異
- **エラーハンドリング**: `setopt ERR_EXIT` vs `set -e`
- **入力処理**: `vared`コマンドでより洗練された入力
- **条件分岐**: `[[ ]]` での厳密な条件評価
- **nvm統合**: Zsh環境でのnvm設定自動読み込み

### Makefile実装

#### 設計思想
- **シンプルなコマンド**: 覚えやすい短縮コマンド
- **ヘルプ機能**: `make help`で全コマンド表示
- **学習支援**: 学習用のブランチ管理機能

#### 主要ターゲット
```makefile
help:           # ヘルプ表示
setup:          # インタラクティブセットアップ
install:        # 依存関係インストール
dev:            # ローカル開発サーバー
dev-docker:     # Docker開発サーバー
build:          # ローカルビルド
build-docker:   # Dockerイメージビルド
clean:          # ローカル環境クリーンアップ
clean-docker:   # Docker環境クリーンアップ
lint:           # ESLintチェック
learn-start:    # 学習ブランチ作成
learn-reset:    # mainブランチへの復帰
```

#### 学習支援機能
```makefile
learn-start:
	@echo "🎓 新しい学習セッションを開始します..."
	@read -p "新しい学習ブランチ名を入力してください: " branch; \
	git checkout -b learn/$$branch

learn-reset:
	@echo "🔄 学習環境をリセットします..."
	git checkout main
	git pull origin main 2>/dev/null || echo "リモートからのpullに失敗（ローカルのみ）"
```

## .gitignore最適化

### 追加項目の検討

#### IDE・エディタ対応
```ignore
# IDEs and editors
.vscode/        # Visual Studio Code
.idea/          # IntelliJ IDEA
*.swp           # Vim
*.swo           # Vim
*~              # Emacs
```

#### OS固有ファイル
```ignore
# OS generated files
.DS_Store       # macOS
.DS_Store?      # macOS
._*             # macOS
.Spotlight-V100 # macOS
.Trashes        # macOS
ehthumbs.db     # Windows
Thumbs.db       # Windows
```

#### 開発関連
```ignore
# Docker
.docker/

# Temporary files
tmp/
temp/

# Logs
logs
*.log
```

#### パッケージマネージャー考慮
```ignore
# Package manager locks (uncomment if you want to ignore them)
# package-lock.json
# yarn.lock
# pnpm-lock.yaml
```

**判断**: 学習テンプレートとしてはlockファイルをコミットして完全固定化

## package.jsonスクリプト拡張

### 追加されたスクリプト
```json
{
  "scripts": {
    "docker:dev": "docker-compose up next-tpl-dev",
    "docker:build": "docker build -t next-tpl .",
    "docker:run": "docker run -p 3000:3000 next-tpl",
    "check-updates": "npm outdated",
    "audit-security": "npm audit",
    "update-safe": "npm update && npm audit fix"
  }
}
```

### 実行権限設定
```bash
chmod +x /home/tani09/allprojects/next-tpl/setup.sh
```

## 開発ワークフロー最適化

### 推奨開発パターン

#### パターン1: 個人学習
```bash
# 新しい学習プロジェクト開始
git clone https://github.com/user/next-tpl.git learn-routing
cd learn-routing
make learn-start
# ブランチ名入力: routing-practice
make dev
```

#### パターン2: Docker学習
```bash
git clone https://github.com/user/next-tpl.git docker-practice
cd docker-practice
make dev-docker
```

#### パターン3: 実験環境
```bash
git clone https://github.com/user/next-tpl.git experiment
cd experiment
make setup
# 選択: 3) 両方セットアップ
```

### 環境リセット手順
```bash
# ローカル環境のリセット
make clean
make install

# Docker環境のリセット
make clean-docker
make build-docker

# 学習環境のリセット
make learn-reset
```

## エラーハンドリングと検証

### ツール構造による改善点
- **組織化**: スクリプトの論理的配置
- **選択肢**: シェル環境に応じた最適スクリプト
- **保守性**: 機能別ファイル分割
- **拡張性**: 新しいツールの追加が容易

### セットアップスクリプトの堅牢性
- **Bash版**: `set -e`でエラー時の即座終了
- **Zsh版**: `setopt ERR_EXIT`でより厳密なエラーハンドリング
- コマンド存在確認: `command -v`
- 条件分岐での適切なフォールバック
- ユーザーフレンドリーなメッセージ

### シェル自動選択の信頼性
- `$SHELL`環境変数による現在シェル検出
- 未対応シェルでのbashフォールバック
- execによる適切なプロセス置換

### Makefileの信頼性
- `.PHONY`ターゲット明示
- エラー時の適切な終了コード
- 依存関係の明確化

## 成果と効果

### 自動化達成レベル
- ✅ ワンコマンドセットアップ: `./setup`（シェル自動選択）
- ✅ シェル対応セットアップ: `bash tools/setup.sh` / `zsh tools/setup.zsh`
- ✅ 簡単開発開始: `make dev`
- ✅ 学習ブランチ管理: `make learn-start`
- ✅ 環境リセット: `make clean`

### ツール構造による改善
1. **シェル最適化**: ユーザー環境に最適なスクリプト実行
2. **組織化**: tools/ディレクトリでの論理的配置
3. **保守性**: 機能別ファイル分割による管理しやすさ
4. **拡張性**: 新機能追加の容易さ

### 学習者体験向上
1. **即座開始**: git clone → setup → 開発開始
2. **環境適応**: Bash/Zsh自動選択でストレスフリー
3. **選択肢提示**: 環境に応じた最適セットアップ
4. **失敗回復**: 簡単なリセット手順
5. **学習管理**: ブランチでの学習内容整理

---
**関連記録**:
- [02-docker-environment.md](./02-docker-environment.md) - Docker環境構築とバージョン固定
- [04-documentation-strategy.md](./04-documentation-strategy.md) - ドキュメント整備とバージョン戦略
