# 自動化スクリプト詳細実装記録

## 概要

プロジェクトセットアップとメンテナンスの完全自動化実装記録

## メインセットアップスクリプト

### シェル自動検出機能 (setup)

```bash
#!/bin/bash
# メインセットアップスクリプト - シェル自動選択

# 現在のシェル検出
CURRENT_SHELL=$(basename "$SHELL")

echo "🔍 検出されたシェル: $CURRENT_SHELL"

# プロジェクトルート検出
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# シェル別スクリプト実行
case "$CURRENT_SHELL" in
    "zsh")
        echo "🚀 Zsh用セットアップを実行します..."
        exec "$PROJECT_ROOT/tools/setup.zsh"
        ;;
    "bash")
        echo "🚀 Bash用セットアップを実行します..."
        exec "$PROJECT_ROOT/tools/setup.sh"
        ;;
    *)
        echo "⚠️  不明なシェル: $CURRENT_SHELL"
        echo "🔄 Bash用セットアップを試行します..."
        exec "$PROJECT_ROOT/tools/setup.sh"
        ;;
esac
```

### Zsh専用セットアップ (tools/setup.zsh)

```zsh
#!/usr/bin/env zsh

# Zsh固有機能を活用したセットアップ
setopt EXTENDED_GLOB NULL_GLOB

# プロジェクトルート自動検出
PROJECT_ROOT=${0:A:h:h}

# カラー出力設定
autoload -U colors && colors

setup_info() {
    print -P "%F{blue}ℹ️  $1%f"
}

setup_success() {
    print -P "%F{green}✅ $1%f"
}

setup_error() {
    print -P "%F{red}❌ $1%f"
}

# Node.js バージョン管理
check_node_version() {
    local required_version="22.11.0"

    if command -v node >/dev/null 2>&1; then
        local current_version=$(node --version | cut -d'v' -f2)

        if [[ "$current_version" == "$required_version" ]]; then
            setup_success "Node.js $required_version が検出されました"
            return 0
        else
            setup_info "現在のNode.js: v$current_version"
        fi
    fi

    # nvm使用時の自動切り替え
    if command -v nvm >/dev/null 2>&1; then
        setup_info "nvmでNode.js $required_version に切り替えます..."
        nvm use "$required_version" || nvm install "$required_version"
        return $?
    fi

    setup_error "Node.js $required_version が必要です"
    return 1
}
```

## クリーンアップスクリプト

### 高機能クリーンアップ (tools/cleanup.zsh)

```zsh
#!/usr/bin/env zsh

# 削除対象ファイル定義
CLEANUP_PATTERNS=(
    # ビルド成果物
    ".next"
    "out"
    "build"
    ".nuxt"

    # 一時ファイル
    "*.tmp"
    "*.log"
    "logs"

    # OS生成ファイル
    ".DS_Store"
    "Thumbs.db"
    "desktop.ini"

    # エディタファイル
    "*.swp"
    "*.swo"
    "*~"
    ".vscode/settings.json"

    # キャッシュファイル
    ".eslintcache"
    "*.tsbuildinfo"
    ".turbo"
)

# 除外ディレクトリ
EXCLUDE_DIRS=(
    ".git"
    "node_modules"
    ".vscode"
)

# ドライランモード
dry_run_cleanup() {
    print -P "%F{yellow}🔍 削除対象ファイルを検索中...%f"

    local count=0
    for pattern in $CLEANUP_PATTERNS; do
        local files=(${~pattern})
        if [[ ${#files[@]} -gt 0 && "${files[1]}" != "$pattern" ]]; then
            for file in $files; do
                if [[ -e "$file" ]]; then
                    print -P "%F{red}  🗑️  $file%f"
                    ((count++))
                fi
            done
        fi
    done

    if [[ $count -eq 0 ]]; then
        print -P "%F{green}✨ 削除対象ファイルは見つかりませんでした%f"
    else
        print -P "%F{yellow}📊 合計 $count 個のファイルが削除対象です%f"
    fi
}

# 実際のクリーンアップ実行
execute_cleanup() {
    local count=0
    local errors=0

    for pattern in $CLEANUP_PATTERNS; do
        local files=(${~pattern})
        if [[ ${#files[@]} -gt 0 && "${files[1]}" != "$pattern" ]]; then
            for file in $files; do
                if [[ -e "$file" ]]; then
                    if rm -rf "$file" 2>/dev/null; then
                        print -P "%F{green}✅ 削除: $file%f"
                        ((count++))
                    else
                        print -P "%F{red}❌ 削除失敗: $file%f"
                        ((errors++))
                    fi
                fi
            done
        fi
    done

    print -P "%F{blue}📊 削除完了: $count 個 | エラー: $errors 個%f"
}
```

## Docker統合スクリプト

### Docker環境管理

```bash
# Makefile統合コマンド
docker_setup() {
    setup_info "🐳 Docker環境を確認中..."

    if ! command -v docker >/dev/null 2>&1; then
        setup_error "Dockerが見つかりません"
        return 1
    fi

    if ! command -v docker-compose >/dev/null 2>&1; then
        setup_error "Docker Composeが見つかりません"
        return 1
    fi

    setup_success "Docker環境が利用可能です"

    # Docker開発環境起動選択
    if ask_user "Docker開発環境で起動しますか？"; then
        make dev-docker
    fi
}
```

## 設定ファイル管理

### .gitignore自動生成

```bash
generate_gitignore() {
    local gitignore_content="# Next.js
.next/
out/
build/

# dependencies
node_modules/

# logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# local env files
.env*.local

# vercel
.vercel

# typescript
*.tsbuildinfo
next-env.d.ts

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Editor files
*.swp
*.swo
*~

# IDEs
.vscode/settings.json
.idea/

# Cache directories
.eslintcache
.turbo/"

    echo "$gitignore_content" > .gitignore
    setup_success ".gitignore を生成しました"
}
```

## パッケージ管理

### 依存関係インストール自動化

```bash
install_dependencies() {
    setup_info "📦 依存関係をインストール中..."

    # パッケージマネージャー検出
    if [[ -f "package-lock.json" ]]; then
        npm ci
    elif [[ -f "yarn.lock" ]]; then
        yarn install --frozen-lockfile
    elif [[ -f "pnpm-lock.yaml" ]]; then
        pnpm install --frozen-lockfile
    else
        npm install
    fi

    if [[ $? -eq 0 ]]; then
        setup_success "依存関係のインストールが完了しました"
    else
        setup_error "依存関係のインストールに失敗しました"
        return 1
    fi
}
```

## エラーハンドリング

### 堅牢なエラー処理

```zsh
# エラー時の自動復旧
error_recovery() {
    local exit_code=$?

    print -P "%F{red}💥 エラーが発生しました (終了コード: $exit_code)%f"

    case $exit_code in
        1)
            print -P "%F{yellow}🔧 一般的なエラーです。設定を確認してください%f"
            ;;
        126)
            print -P "%F{yellow}🔧 実行権限がありません。chmod +x で権限を付与してください%f"
            ;;
        127)
            print -P "%F{yellow}🔧 コマンドが見つかりません。パスを確認してください%f"
            ;;
        *)
            print -P "%F{yellow}🔧 予期しないエラーです。ログを確認してください%f"
            ;;
    esac

    # クリーンアップ処理
    cleanup_on_error
}

# エラー時のトラップ設定
trap error_recovery ERR
```

## ログとデバッグ

### 詳細ログ出力

```bash
# ログファイル管理
LOG_FILE="setup-$(date +%Y%m%d-%H%M%S).log"

log_command() {
    local cmd="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 実行: $cmd" >> "$LOG_FILE"
    eval "$cmd" 2>&1 | tee -a "$LOG_FILE"
    return ${PIPESTATUS[0]}
}

# デバッグモード
if [[ "$DEBUG" == "1" ]]; then
    set -x  # コマンド実行をトレース
fi
```

## 今後の拡張予定

### 機能追加計画

- CI/CD統合
- 自動テスト実行
- パフォーマンス測定
- セキュリティスキャン

### プラットフォーム対応

- Windows PowerShell対応
- macOS特化最適化
- Linux ディストリビューション別対応

---

**作成**: 2025/10/27 **更新**: 自動化スクリプト完成時 **技術**: Bash, Zsh, Make,
Docker
