#!/usr/bin/env zsh

# 依存関係管理ツール - パッケージ更新・セキュリティ監査
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
    print -P "%F{cyan}📦 依存関係管理ツール%f"
    echo ""
    echo "使用方法: ./tools/deps-manager.zsh [コマンド] [オプション]"
    echo ""
    echo "📋 利用可能なコマンド:"
    echo ""
    echo "  check, c              現在の依存関係をチェック"
    echo "  outdated, o           古いパッケージを確認"
    echo "  update, u             パッケージを安全に更新"
    echo "  audit, a              セキュリティ脆弱性をチェック"
    echo "  fix, f                脆弱性を自動修正"
    echo "  clean, cl             不要なパッケージをクリーンアップ"
    echo "  analyze, an           依存関係を詳細分析"
    echo "  backup, b             現在の状態をバックアップ"
    echo "  restore, r            バックアップから復元"
    echo "  report, rp            完全なレポートを生成"
    echo ""
    echo "🎯 オプション:"
    echo "  --dry-run, -n         実行内容のプレビュー"
    echo "  --force, -f           強制実行"
    echo "  --save-backup, -s     更新前に自動バックアップ"
    echo "  --dev-only, -d        開発依存関係のみ対象"
    echo "  --prod-only, -p       本番依存関係のみ対象"
    echo ""
    echo "🎯 使用例:"
    echo "  ./tools/deps-manager.zsh check          # 依存関係チェック"
    echo "  ./tools/deps-manager.zsh update --save-backup # バックアップ付き更新"
    echo "  ./tools/deps-manager.zsh audit          # セキュリティ監査"
    echo "  ./tools/deps-manager.zsh report         # 完全レポート生成"
}

# バックアップ作成
create_backup() {
    local timestamp=$(date +"%Y%m%d-%H%M%S")
    local backup_dir="backups/deps-$timestamp"
    
    print_step "依存関係をバックアップしています..."
    
    mkdir -p "$backup_dir"
    
    # package.json と lock ファイルをバックアップ
    cp package.json "$backup_dir/" 2>/dev/null || true
    cp package-lock.json "$backup_dir/" 2>/dev/null || true
    cp yarn.lock "$backup_dir/" 2>/dev/null || true
    cp pnpm-lock.yaml "$backup_dir/" 2>/dev/null || true
    
    # node_modules の情報も記録
    if [[ -d "node_modules" ]]; then
        npm list --depth=0 > "$backup_dir/installed-packages.txt" 2>/dev/null || true
    fi
    
    print_success "バックアップを作成しました: $backup_dir"
    echo "$backup_dir" > .last-deps-backup
}

# バックアップから復元
restore_backup() {
    local backup_path="$1"
    
    if [[ -z "$backup_path" && -f ".last-deps-backup" ]]; then
        backup_path=$(cat .last-deps-backup)
    fi
    
    if [[ -z "$backup_path" ]]; then
        print_error "復元するバックアップが指定されていません"
        
        # 利用可能なバックアップを表示
        if [[ -d "backups" ]]; then
            echo ""
            print_info "利用可能なバックアップ:"
            ls -la backups/ | grep "deps-" | while read -r line; do
                echo "  $line"
            done
        fi
        return 1
    fi
    
    if [[ ! -d "$backup_path" ]]; then
        print_error "バックアップディレクトリが見つかりません: $backup_path"
        return 1
    fi
    
    print_step "バックアップから復元しています..."
    
    # ファイルを復元
    cp "$backup_path/package.json" . 2>/dev/null && print_success "package.json を復元しました"
    cp "$backup_path/package-lock.json" . 2>/dev/null && print_success "package-lock.json を復元しました"
    
    # node_modules を再構築
    print_step "依存関係を再インストールしています..."
    rm -rf node_modules
    npm install
    
    print_success "バックアップからの復元が完了しました"
}

# 依存関係チェック
check_dependencies() {
    print_info "依存関係をチェックしています..."
    echo ""
    
    # package.json の存在確認
    if [[ ! -f "package.json" ]]; then
        print_error "package.json が見つかりません"
        return 1
    fi
    
    # Node.js バージョンチェック
    local node_version=$(node --version 2>/dev/null || echo "未インストール")
    print_info "Node.js バージョン: $node_version"
    
    # npm バージョンチェック
    local npm_version=$(npm --version 2>/dev/null || echo "未インストール")
    print_info "npm バージョン: $npm_version"
    
    # パッケージ情報
    local package_count=$(npm list --depth=0 2>/dev/null | grep -c "├──\|└──" || echo "0")
    print_info "インストール済みパッケージ数: $package_count"
    
    # ロックファイルの状態
    if [[ -f "package-lock.json" ]]; then
        print_success "package-lock.json が存在します"
        local lock_date=$(stat -c %y package-lock.json 2>/dev/null | cut -d' ' -f1)
        print_info "最終更新日: $lock_date"
    else
        print_warning "package-lock.json が存在しません"
    fi
    
    # node_modules の状態
    if [[ -d "node_modules" ]]; then
        local node_modules_size=$(du -sh node_modules 2>/dev/null | cut -f1)
        print_success "node_modules が存在します (サイズ: $node_modules_size)"
    else
        print_warning "node_modules が存在しません"
    fi
    
    echo ""
    print_info "基本的なヘルスチェック:"
    
    # 重要なパッケージの確認
    local important_packages=("react" "next" "typescript" "@types/react")
    for pkg in $important_packages; do
        if npm list "$pkg" >/dev/null 2>&1; then
            local version=$(npm list "$pkg" --depth=0 | grep "$pkg" | sed 's/.*@//' | sed 's/ .*//')
            print_success "$pkg@$version"
        else
            print_warning "$pkg が見つかりません"
        fi
    done
}

# 古いパッケージチェック
check_outdated() {
    print_info "古いパッケージをチェックしています..."
    echo ""
    
    local outdated_output=$(npm outdated --json 2>/dev/null || echo "{}")
    
    if [[ "$outdated_output" == "{}" ]]; then
        print_success "すべてのパッケージが最新です"
        return 0
    fi
    
    print_warning "以下のパッケージが古くなっています:"
    echo ""
    
    # JSON をパースして表形式で表示
    echo "$outdated_output" | jq -r 'to_entries[] | "\(.key): \(.value.current) → \(.value.latest)"' 2>/dev/null || {
        # jq が利用できない場合の代替
        npm outdated
    }
    
    echo ""
    local count=$(echo "$outdated_output" | jq 'length' 2>/dev/null || echo "不明")
    print_info "$count 個のパッケージが更新可能です"
}

# セキュリティ監査
security_audit() {
    print_info "セキュリティ脆弱性をチェックしています..."
    echo ""
    
    local audit_output=$(npm audit --json 2>/dev/null || echo "{}")
    
    # 脆弱性の数を取得
    local vulnerabilities=$(echo "$audit_output" | jq '.metadata.vulnerabilities.total // 0' 2>/dev/null || echo "0")
    
    if [[ "$vulnerabilities" -eq 0 ]]; then
        print_success "脆弱性は見つかりませんでした"
        return 0
    fi
    
    print_warning "$vulnerabilities 件の脆弱性が見つかりました"
    echo ""
    
    # 詳細な監査結果
    npm audit --audit-level=low 2>/dev/null || {
        print_error "監査の実行に失敗しました"
        return 1
    }
    
    echo ""
    print_info "修正可能な脆弱性がある場合は 'fix' コマンドを実行してください"
}

# 脆弱性修正
fix_vulnerabilities() {
    local force="$1"
    
    print_info "脆弱性の修正を開始します..."
    
    # バックアップ作成
    create_backup
    
    # 自動修正実行
    print_step "自動修正を実行しています..."
    
    if [[ "$force" == "true" ]]; then
        npm audit fix --force
    else
        npm audit fix
    fi
    
    # 修正後の監査
    echo ""
    print_step "修正後の状態をチェックしています..."
    security_audit
}

# パッケージ更新
update_packages() {
    local dry_run="$1"
    local save_backup="$2"
    local dev_only="$3"
    local prod_only="$4"
    
    if [[ "$save_backup" == "true" ]]; then
        create_backup
    fi
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "更新対象パッケージをプレビューしています..."
        npm outdated
        return 0
    fi
    
    print_step "パッケージを更新しています..."
    
    # 更新対象を決定
    if [[ "$dev_only" == "true" ]]; then
        print_info "開発依存関係のみ更新します..."
        npm update --save-dev
    elif [[ "$prod_only" == "true" ]]; then
        print_info "本番依存関係のみ更新します..."
        npm update --save-prod
    else
        print_info "すべての依存関係を更新します..."
        npm update
    fi
    
    print_success "パッケージの更新が完了しました"
    
    # 更新後の確認
    echo ""
    print_step "更新後の状態をチェックしています..."
    check_dependencies
}

# 不要パッケージクリーンアップ
clean_packages() {
    print_info "不要なパッケージをクリーンアップしています..."
    
    # 未使用パッケージの検出（簡易版）
    print_step "使用されていないパッケージをチェックしています..."
    
    # package.json を分析
    local dependencies=$(jq -r '.dependencies // {} | keys[]' package.json 2>/dev/null)
    local dev_dependencies=$(jq -r '.devDependencies // {} | keys[]' package.json 2>/dev/null)
    
    # 実際のコードで使用されているかチェック（簡易）
    local unused_packages=()
    
    for pkg in $(echo "$dependencies"); do
        if ! grep -r "import.*$pkg\|require.*$pkg\|from.*$pkg" app/ components/ 2>/dev/null | grep -q .; then
            if ! grep -q "$pkg" next.config.* tailwind.config.* 2>/dev/null; then
                unused_packages+=($pkg)
            fi
        fi
    done
    
    if [[ ${#unused_packages[@]} -eq 0 ]]; then
        print_success "未使用のパッケージは見つかりませんでした"
    else
        print_warning "以下のパッケージが未使用の可能性があります:"
        for pkg in $unused_packages; do
            echo "  - $pkg"
        done
        echo ""
        print_info "手動で確認してから削除することをお勧めします"
    fi
    
    # npm の自動クリーンアップ
    print_step "npm キャッシュをクリーンアップしています..."
    npm cache clean --force 2>/dev/null || true
    
    print_success "クリーンアップが完了しました"
}

# 依存関係分析
analyze_dependencies() {
    print_info "依存関係を詳細分析しています..."
    echo ""
    
    # パッケージサイズ分析
    print_info "📊 パッケージサイズ分析:"
    if command -v du >/dev/null 2>&1 && [[ -d "node_modules" ]]; then
        du -sh node_modules/* 2>/dev/null | sort -hr | head -10 | while read -r line; do
            echo "  $line"
        done
    fi
    
    echo ""
    
    # 依存関係ツリー
    print_info "🌳 依存関係ツリー (上位レベル):"
    npm list --depth=1 2>/dev/null | head -20
    
    echo ""
    
    # ライセンス情報
    print_info "📜 ライセンス情報:"
    npm list --json 2>/dev/null | jq -r '.dependencies | to_entries[] | select(.value.license) | "\(.key): \(.value.license)"' 2>/dev/null | head -10 || {
        print_warning "ライセンス情報の取得に失敗しました"
    }
    
    echo ""
    
    # バンドルサイズ推定
    if [[ -f ".next/static" ]]; then
        print_info "📦 ビルドサイズ情報:"
        du -sh .next/static/* 2>/dev/null | while read -r line; do
            echo "  $line"
        done
    fi
}

# 完全レポート生成
generate_report() {
    local report_file="deps-report-$(date +%Y%m%d-%H%M%S).md"
    
    print_info "完全なレポートを生成しています..."
    
    cat > "$report_file" << EOF
# 依存関係レポート

生成日時: $(date)
プロジェクト: $(basename $(pwd))

## 環境情報

- Node.js: $(node --version 2>/dev/null || echo "未インストール")
- npm: $(npm --version 2>/dev/null || echo "未インストール")
- OS: $(uname -s) $(uname -r)

## パッケージ情報

### 本番依存関係
$(npm list --prod --depth=0 2>/dev/null | tail -n +2 || echo "なし")

### 開発依存関係
$(npm list --dev --depth=0 2>/dev/null | tail -n +2 || echo "なし")

## セキュリティ監査

$(npm audit 2>/dev/null || echo "監査情報なし")

## 古いパッケージ

$(npm outdated 2>/dev/null || echo "すべて最新")

## ファイルサイズ

- node_modules: $(du -sh node_modules 2>/dev/null | cut -f1 || echo "不明")
- package.json: $(stat -c%s package.json 2>/dev/null || echo "不明") bytes
- package-lock.json: $(stat -c%s package-lock.json 2>/dev/null || echo "不明") bytes

---
Generated by deps-manager.zsh
EOF
    
    print_success "レポートを生成しました: $report_file"
}

# メイン処理
main() {
    local command="$1"
    shift
    
    local dry_run="false"
    local force="false"
    local save_backup="false"
    local dev_only="false"
    local prod_only="false"
    
    # オプション解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run|-n)
                dry_run="true"
                ;;
            --force|-f)
                force="true"
                ;;
            --save-backup|-s)
                save_backup="true"
                ;;
            --dev-only|-d)
                dev_only="true"
                ;;
            --prod-only|-p)
                prod_only="true"
                ;;
            *)
                print_error "不明なオプション: $1"
                return 1
                ;;
        esac
        shift
    done
    
    # コマンド実行
    case "$command" in
        "check"|"c")
            check_dependencies
            ;;
        "outdated"|"o")
            check_outdated
            ;;
        "update"|"u")
            update_packages "$dry_run" "$save_backup" "$dev_only" "$prod_only"
            ;;
        "audit"|"a")
            security_audit
            ;;
        "fix"|"f")
            fix_vulnerabilities "$force"
            ;;
        "clean"|"cl")
            clean_packages
            ;;
        "analyze"|"an")
            analyze_dependencies
            ;;
        "backup"|"b")
            create_backup
            ;;
        "restore"|"r")
            restore_backup "$2"
            ;;
        "report"|"rp")
            generate_report
            ;;
        "help"|""|*)
            show_help
            ;;
    esac
}

# スクリプト実行
main "$@"