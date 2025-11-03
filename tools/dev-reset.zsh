#!/usr/bin/env zsh

# 開発環境リセット/初期化ツール
# Next.js学習テンプレート用

setopt ERR_EXIT
autoload -U colors && colors

# プロジェクトルート取得
PROJECT_ROOT=${0:A:h:h}
cd "$PROJECT_ROOT"

# ユーティリティ関数
print_info() {
    print -P "%F{blue}ℹ️  $1%f"
}

print_success() {
    print -P "%F{green}✅ $1%f"
}

print_error() {
    print -P "%F{red}❌ $1%f"
}

print_warning() {
    print -P "%F{yellow}⚠️  $1%f"
}

print_step() {
    print -P "%F{cyan}🔄 $1%f"
}

# ヘルプ表示
show_help() {
    print -P "%F{cyan}🔄 開発環境リセット/初期化ツール%f"
    echo ""
    echo "使用方法: ./tools/dev-reset.zsh [オプション]"
    echo ""
    echo "📋 利用可能なオプション:"
    echo ""
    echo "  --full, -f           完全リセット (node_modules, .next, cache等すべて)"
    echo "  --soft, -s           ソフトリセット (ビルド成果物のみ)"
    echo "  --cache-only, -c     キャッシュファイルのみクリア"
    echo "  --git-clean, -g      Gitの未追跡ファイルもクリーンアップ"
    echo "  --docker, -d         Docker環境もリセット"
    echo "  --dry-run, -n        実行内容のプレビュー（実際には削除しない）"
    echo "  --interactive, -i    インタラクティブモード"
    echo "  --help, -h           このヘルプを表示"
    echo ""
    echo "🎯 使用例:"
    echo "  ./tools/dev-reset.zsh --soft           # ビルド成果物のみ削除"
    echo "  ./tools/dev-reset.zsh --full           # 完全リセット"
    echo "  ./tools/dev-reset.zsh --docker         # Docker環境込みでリセット"
    echo "  ./tools/dev-reset.zsh --dry-run --full # 削除対象をプレビュー"
    echo ""
    echo "⚠️  注意: --full オプションは慎重に使用してください"
}

# 削除対象ファイル・ディレクトリ定義
declare -A RESET_TARGETS=(
    ["cache"]="キャッシュファイル"
    ["build"]="ビルド成果物"
    ["deps"]="依存関係"
    ["git"]="Git未追跡ファイル"
    ["docker"]="Docker関連"
)

declare -A CACHE_PATTERNS=(
    [".next"]="Next.js ビルドキャッシュ"
    [".turbo"]="Turbopack キャッシュ"
    ["out"]="静的エクスポート出力"
    ["*.log"]="ログファイル"
    ["logs"]="ログディレクトリ"
    [".eslintcache"]="ESLint キャッシュ"
    ["*.tsbuildinfo"]="TypeScript ビルド情報"
    [".DS_Store"]="macOS システムファイル"
    ["Thumbs.db"]="Windows システムファイル"
    ["desktop.ini"]="Windows システムファイル"
    ["*.tmp"]="一時ファイル"
    ["*.swp"]="Vim一時ファイル"
    ["*.swo"]="Vim一時ファイル"
    ["*~"]="エディタバックアップファイル"
)

declare -A BUILD_PATTERNS=(
    ["build"]="ビルド出力ディレクトリ"
    ["dist"]="配布用ディレクトリ"
    [".nuxt"]="Nuxt.js ビルド (混在プロジェクト用)"
)

declare -A DEPS_PATTERNS=(
    ["node_modules"]="Node.js 依存関係"
    ["package-lock.json"]="npm ロックファイル"
    ["yarn.lock"]="Yarn ロックファイル"
    ["pnpm-lock.yaml"]="pnpm ロックファイル"
)

# ファイル削除実行
execute_removal() {
    local pattern="$1"
    local description="$2"
    local dry_run="$3"
    
    # グロブパターンで該当ファイル検索
    local files=(${~pattern})
    
    # 該当するファイルが存在するかチェック
    if [[ ${#files[@]} -gt 0 && "${files[1]}" != "$pattern" ]]; then
        for file in $files; do
            if [[ -e "$file" ]]; then
                if [[ "$dry_run" == "true" ]]; then
                    local size=""
                    if [[ -f "$file" ]]; then
                        size=" ($(du -sh "$file" 2>/dev/null | cut -f1 || echo "不明"))"
                    elif [[ -d "$file" ]]; then
                        size=" ($(du -sh "$file" 2>/dev/null | cut -f1 || echo "不明"))"
                    fi
                    echo "  📁 $file$size"
                else
                    print_step "削除中: $file"
                    if [[ -d "$file" ]]; then
                        rm -rf "$file" && print_success "削除完了: $file" || print_error "削除失敗: $file"
                    else
                        rm -f "$file" && print_success "削除完了: $file" || print_error "削除失敗: $file"
                    fi
                fi
            fi
        done
    fi
}

# カテゴリ別削除実行
process_category() {
    local category="$1"
    local dry_run="$2"
    
    case "$category" in
        "cache")
            print_info "キャッシュファイルをクリーンアップしています..."
            for pattern description in ${(kv)CACHE_PATTERNS}; do
                execute_removal "$pattern" "$description" "$dry_run"
            done
            ;;
        "build")
            print_info "ビルド成果物をクリーンアップしています..."
            for pattern description in ${(kv)BUILD_PATTERNS}; do
                execute_removal "$pattern" "$description" "$dry_run"
            done
            ;;
        "deps")
            print_info "依存関係をクリーンアップしています..."
            for pattern description in ${(kv)DEPS_PATTERNS}; do
                execute_removal "$pattern" "$description" "$dry_run"
            done
            ;;
        "git")
            print_info "Git未追跡ファイルをクリーンアップしています..."
            if [[ "$dry_run" == "true" ]]; then
                git clean -ndx | while read -r line; do
                    echo "  🗑️  ${line#Would remove }"
                done
            else
                git clean -fdx
                print_success "Git未追跡ファイルを削除しました"
            fi
            ;;
        "docker")
            print_info "Docker環境をクリーンアップしています..."
            if [[ "$dry_run" == "true" ]]; then
                echo "  🐳 Docker コンテナとボリュームを停止・削除"
                echo "  🐳 Docker システムクリーンアップ"
            else
                if command -v docker-compose >/dev/null 2>&1; then
                    docker-compose down -v 2>/dev/null || true
                fi
                docker system prune -f 2>/dev/null || true
                print_success "Docker環境をクリーンアップしました"
            fi
            ;;
    esac
}

# 対話的モード
interactive_mode() {
    print_info "対話的リセットモードを開始します..."
    echo ""
    
    local categories=()
    
    # カテゴリ選択
    for category description in ${(kv)RESET_TARGETS}; do
        read -q "?$description をクリーンアップしますか? (y/N): " && {
            echo
            categories+=($category)
        } || echo
    done
    
    if [[ ${#categories[@]} -eq 0 ]]; then
        print_warning "何も選択されませんでした"
        return 0
    fi
    
    echo ""
    print_info "選択されたカテゴリ:"
    for category in $categories; do
        echo "  - ${RESET_TARGETS[$category]}"
    done
    
    echo ""
    read -q "?実行しますか? (y/N): " && {
        echo
        for category in $categories; do
            process_category "$category" "false"
        done
        print_success "リセット完了"
    } || {
        echo
        print_info "キャンセルされました"
    }
}

# プレビューモード
preview_mode() {
    local categories=("$@")
    
    print_info "削除対象ファイルをプレビューしています..."
    echo ""
    
    for category in $categories; do
        echo "📂 ${RESET_TARGETS[$category]}:"
        process_category "$category" "true"
        echo ""
    done
    
    print_warning "実際の削除を行う場合は --dry-run オプションを外してください"
}

# 環境復旧
restore_environment() {
    print_info "環境復旧を開始します..."
    
    # Node.js バージョンチェック
    if command -v node >/dev/null 2>&1; then
        local current_version=$(node --version)
        print_info "Node.js バージョン: $current_version"
        
        if [[ "$current_version" != "v22.11.0" ]]; then
            print_warning "推奨バージョン v22.11.0 と異なります"
            
            if command -v nvm >/dev/null 2>&1; then
                read -q "?nvm で v22.11.0 に切り替えますか? (y/N): " && {
                    echo
                    nvm use 22.11.0 || nvm install 22.11.0
                } || echo
            fi
        fi
    fi
    
    # 依存関係の再インストール
    if [[ ! -d "node_modules" ]]; then
        print_step "依存関係を再インストールしています..."
        npm install || {
            print_error "依存関係のインストールに失敗しました"
            return 1
        }
        print_success "依存関係のインストールが完了しました"
    fi
    
    # プロジェクトの整合性チェック
    print_step "プロジェクトの整合性をチェックしています..."
    npm run type-check || {
        print_warning "TypeScript の型チェックでエラーが発生しました"
    }
    
    print_success "環境復旧が完了しました"
}

# メイン処理
main() {
    local categories=()
    local dry_run="false"
    local interactive="false"
    local with_restore="false"
    
    # オプション解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --full|-f)
                categories+=("cache" "build" "deps")
                with_restore="true"
                ;;
            --soft|-s)
                categories+=("cache" "build")
                ;;
            --cache-only|-c)
                categories+=("cache")
                ;;
            --git-clean|-g)
                categories+=("git")
                ;;
            --docker|-d)
                categories+=("docker")
                ;;
            --dry-run|-n)
                dry_run="true"
                ;;
            --interactive|-i)
                interactive="true"
                ;;
            --help|-h)
                show_help
                return 0
                ;;
            *)
                print_error "不明なオプション: $1"
                show_help
                return 1
                ;;
        esac
        shift
    done
    
    # デフォルト動作
    if [[ ${#categories[@]} -eq 0 && "$interactive" != "true" ]]; then
        print_info "オプションが指定されていません。ヘルプを表示します。"
        echo ""
        show_help
        return 0
    fi
    
    # 対話的モード
    if [[ "$interactive" == "true" ]]; then
        interactive_mode
        return $?
    fi
    
    # プレビューモード
    if [[ "$dry_run" == "true" ]]; then
        preview_mode $categories
        return 0
    fi
    
    # 実行前確認
    if [[ ${#categories[@]} -gt 0 ]]; then
        echo ""
        print_warning "以下のカテゴリをクリーンアップします:"
        for category in $categories; do
            echo "  - ${RESET_TARGETS[$category]}"
        done
        echo ""
        read -q "?続行しますか? (y/N): " && echo || {
            echo
            print_info "キャンセルされました"
            return 0
        }
        
        # 実行
        for category in $categories; do
            process_category "$category" "false"
        done
        
        # 環境復旧
        if [[ "$with_restore" == "true" ]]; then
            echo ""
            restore_environment
        fi
        
        print_success "開発環境のリセットが完了しました"
    fi
}

# スクリプト実行
main "$@"