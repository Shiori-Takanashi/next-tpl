#!/usr/bin/env zsh

# デプロイ支援ツール - ビルド・デプロイ自動化
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
    print -P "%F{cyan}🚀 デプロイ支援ツール%f"
    echo ""
    echo "使用方法: ./tools/deploy.zsh [コマンド] [オプション]"
    echo ""
    echo "📋 利用可能なコマンド:"
    echo ""
    echo "  build, b              本番ビルドを実行"
    echo "  preview, p            ビルド結果をプレビュー"
    echo "  docker-build, db      Dockerイメージをビルド"
    echo "  docker-run, dr        Dockerコンテナで実行"
    echo "  static, s             静的サイトとしてエクスポート"
    echo "  check, c              デプロイ前チェック"
    echo "  bundle-analyze, ba    バンドルサイズを分析"
    echo "  lighthouse, l         Lighthouseでパフォーマンス測定"
    echo "  deploy-vercel, dv     Vercelにデプロイ"
    echo "  deploy-netlify, dn    Netlifyにデプロイ"
    echo "  clean-build, cb       ビルドファイルをクリーンアップ"
    echo ""
    echo "🎯 オプション:"
    echo "  --env [env]           環境指定 (development|production)"
    echo "  --analyze             バンドル分析を有効化"
    echo "  --clean               ビルド前にクリーンアップ"
    echo "  --verbose, -v         詳細ログ出力"
    echo "  --dry-run, -n         実行内容のプレビュー"
    echo "  --skip-checks         事前チェックをスキップ"
    echo ""
    echo "🎯 使用例:"
    echo "  ./tools/deploy.zsh build --clean        # クリーンビルド"
    echo "  ./tools/deploy.zsh preview              # ローカルプレビュー"
    echo "  ./tools/deploy.zsh check                # デプロイ前チェック"
    echo "  ./tools/deploy.zsh docker-build         # Dockerビルド"
}

# 環境変数設定
setup_environment() {
    local env="$1"

    case "$env" in
        "development")
            export NODE_ENV=development
            print_info "開発環境モードに設定しました"
            ;;
        "production")
            export NODE_ENV=production
            print_info "本番環境モードに設定しました"
            ;;
        *)
            if [[ -z "$NODE_ENV" ]]; then
                export NODE_ENV=production
                print_info "デフォルトで本番環境モードに設定しました"
            fi
            ;;
    esac
}

# デプロイ前チェック
pre_deploy_check() {
    print_info "デプロイ前チェックを実行しています..."
    echo ""

    local errors=0

    # 必須ファイルの存在確認
    local required_files=("package.json" "next.config.ts" "app/layout.tsx" "app/page.tsx")

    print_step "必須ファイルをチェックしています..."
    for file in $required_files; do
        if [[ -f "$file" ]]; then
            print_success "$file ✓"
        else
            print_error "$file が見つかりません"
            ((errors++))
        fi
    done

    echo ""

    # 依存関係チェック
    print_step "依存関係をチェックしています..."
    if [[ -d "node_modules" ]]; then
        print_success "node_modules ✓"
    else
        print_error "node_modules が見つかりません。npm install を実行してください"
        ((errors++))
    fi

    # TypeScript型チェック
    print_step "TypeScript型チェックを実行しています..."
    if npm run type-check >/dev/null 2>&1; then
        print_success "TypeScript型チェック ✓"
    else
        print_error "TypeScript型チェックでエラーが発生しました"
        npm run type-check
        ((errors++))
    fi

    # ESLintチェック
    print_step "ESLintチェックを実行しています..."
    if npm run lint >/dev/null 2>&1; then
        print_success "ESLintチェック ✓"
    else
        print_warning "ESLintで警告またはエラーが発生しました"
        npm run lint
    fi

    # パッケージの脆弱性チェック
    print_step "セキュリティ脆弱性をチェックしています..."
    local audit_result=$(npm audit --audit-level=high --json 2>/dev/null)
    local high_vulnerabilities=$(echo "$audit_result" | jq '.metadata.vulnerabilities.high // 0' 2>/dev/null || echo "0")

    if [[ "$high_vulnerabilities" -eq 0 ]]; then
        print_success "高リスクの脆弱性は見つかりませんでした ✓"
    else
        print_warning "$high_vulnerabilities 件の高リスク脆弱性が見つかりました"
        print_info "npm audit fix を実行することをお勧めします"
    fi

    echo ""

    if [[ $errors -eq 0 ]]; then
        print_success "すべてのチェックが完了しました。デプロイ可能です。"
        return 0
    else
        print_error "$errors 件のエラーが見つかりました。修正してからデプロイしてください。"
        return 1
    fi
}

# ビルド実行
build_project() {
    local clean="$1"
    local analyze="$2"
    local verbose="$3"

    if [[ "$clean" == "true" ]]; then
        print_step "ビルドファイルをクリーンアップしています..."
        rm -rf .next out build
        print_success "クリーンアップ完了"
    fi

    print_step "本番ビルドを開始しています..."

    local build_start=$(date +%s)

    if [[ "$verbose" == "true" ]]; then
        npm run build
    else
        if npm run build >/dev/null 2>&1; then
            print_success "ビルドが完了しました"
        else
            print_error "ビルドに失敗しました"
            echo ""
            print_info "詳細なエラー内容:"
            npm run build
            return 1
        fi
    fi

    local build_end=$(date +%s)
    local build_time=$((build_end - build_start))

    print_info "ビルド時間: ${build_time}秒"

    # ビルド結果の分析
    if [[ -d ".next" ]]; then
        local build_size=$(du -sh .next 2>/dev/null | cut -f1)
        print_info "ビルドサイズ: $build_size"

        # 主要なファイルサイズ
        if [[ -d ".next/static" ]]; then
            echo ""
            print_info "主要ファイルサイズ:"
            find .next/static -name "*.js" -exec du -sh {} \; 2>/dev/null | sort -hr | head -5 | while read -r line; do
                echo "  JS: $line"
            done
            find .next/static -name "*.css" -exec du -sh {} \; 2>/dev/null | sort -hr | head -3 | while read -r line; do
                echo "  CSS: $line"
            done
        fi
    fi

    if [[ "$analyze" == "true" ]]; then
        bundle_analyze
    fi
}

# プレビュー実行
preview_build() {
    if [[ ! -d ".next" ]]; then
        print_warning "ビルドファイルが見つかりません。先にビルドを実行しています..."
        build_project "false" "false" "false"
    fi

    print_info "ビルド結果をプレビューしています..."
    print_info "http://localhost:3000 でプレビューを開始します"
    print_warning "Ctrl+C で停止できます"

    npm run start
}

# 静的エクスポート
static_export() {
    print_step "静的サイトとしてエクスポートしています..."

    # next.config.ts で static export が有効か確認
    if ! grep -q "output.*export" next.config.ts 2>/dev/null; then
        print_warning "next.config.ts で静的エクスポートが設定されていません"
        print_info "output: 'export' を next.config.ts に追加してください"
    fi

    # ビルド実行
    build_project "true" "false" "false"

    # エクスポート結果確認
    if [[ -d "out" ]]; then
        local export_size=$(du -sh out 2>/dev/null | cut -f1)
        print_success "静的エクスポートが完了しました"
        print_info "エクスポートサイズ: $export_size"
        print_info "出力ディレクトリ: ./out/"

        # ファイル一覧
        echo ""
        print_info "エクスポートされたファイル:"
        find out -type f -name "*.html" | head -10 | while read -r file; do
            echo "  $file"
        done
    else
        print_error "静的エクスポートに失敗しました"
        return 1
    fi
}

# Dockerビルド
docker_build() {
    local tag="next-tpl"
    local verbose="$1"

    print_step "Dockerイメージをビルドしています..."

    if [[ ! -f "Dockerfile" ]]; then
        print_error "Dockerfile が見つかりません"
        return 1
    fi

    local build_start=$(date +%s)

    if [[ "$verbose" == "true" ]]; then
        docker build -t "$tag" .
    else
        if docker build -t "$tag" . >/dev/null 2>&1; then
            print_success "Dockerイメージのビルドが完了しました"
        else
            print_error "Dockerイメージのビルドに失敗しました"
            echo ""
            print_info "詳細なエラー内容:"
            docker build -t "$tag" .
            return 1
        fi
    fi

    local build_end=$(date +%s)
    local build_time=$((build_end - build_start))

    print_info "ビルド時間: ${build_time}秒"

    # イメージサイズ確認
    local image_size=$(docker images "$tag" --format "table {{.Size}}" | tail -n 1)
    print_info "イメージサイズ: $image_size"

    print_success "Dockerイメージ '$tag' が準備できました"
}

# Docker実行
docker_run() {
    local tag="next-tpl"
    local port="3000"

    # イメージの存在確認
    if ! docker images | grep -q "$tag"; then
        print_warning "Dockerイメージが見つかりません。ビルドを実行しています..."
        docker_build "false"
    fi

    print_info "Dockerコンテナを起動しています..."
    print_info "http://localhost:$port でアクセスできます"
    print_warning "Ctrl+C で停止できます"

    docker run -p "$port:3000" --rm "$tag"
}

# バンドル分析
bundle_analyze() {
    print_step "バンドルサイズを分析しています..."

    if [[ ! -d ".next" ]]; then
        print_warning "ビルドファイルが見つかりません。先にビルドを実行してください"
        return 1
    fi

    # Next.js のビルド分析
    if command -v npx >/dev/null 2>&1; then
        print_info "Next.js Bundle Analyzer を実行しています..."

        # 簡易バンドル分析
        echo ""
        print_info "JavaScript バンドルサイズ:"
        find .next/static/chunks -name "*.js" 2>/dev/null | while read -r file; do
            local size=$(stat -c%s "$file" 2>/dev/null || echo "0")
            local size_kb=$((size / 1024))
            local basename=$(basename "$file")
            echo "  $basename: ${size_kb}KB"
        done | sort -k2 -nr | head -10

        echo ""
        print_info "CSS バンドルサイズ:"
        find .next/static -name "*.css" 2>/dev/null | while read -r file; do
            local size=$(stat -c%s "$file" 2>/dev/null || echo "0")
            local size_kb=$((size / 1024))
            local basename=$(basename "$file")
            echo "  $basename: ${size_kb}KB"
        done | sort -k2 -nr

    else
        print_warning "npx が見つかりません"
    fi
}

# Lighthouse テスト
lighthouse_test() {
    print_step "Lighthouseでパフォーマンステストを実行しています..."

    if ! command -v lighthouse >/dev/null 2>&1; then
        print_warning "Lighthouse がインストールされていません"
        print_info "npm install -g lighthouse でインストールできます"
        return 1
    fi

    # ローカルサーバーが動いているかチェック
    if ! curl -s http://localhost:3000 >/dev/null 2>&1; then
        print_warning "ローカルサーバーが起動していません"
        print_info "npm run start または npm run dev でサーバーを起動してください"
        return 1
    fi

    local report_file="lighthouse-report-$(date +%Y%m%d-%H%M%S).html"

    print_info "Lighthouseレポートを生成しています..."
    lighthouse http://localhost:3000 --output=html --output-path="$report_file" --quiet

    print_success "Lighthouseレポートが生成されました: $report_file"
}

# Vercel デプロイ
deploy_vercel() {
    print_step "Vercelにデプロイしています..."

    if ! command -v vercel >/dev/null 2>&1; then
        print_warning "Vercel CLI がインストールされていません"
        print_info "npm install -g vercel でインストールできます"
        return 1
    fi

    # デプロイ前チェック
    pre_deploy_check || {
        print_error "デプロイ前チェックに失敗しました"
        return 1
    }

    print_info "Vercelデプロイを開始します..."
    vercel --prod

    print_success "Vercelデプロイが完了しました"
}

# Netlify デプロイ
deploy_netlify() {
    print_step "Netlifyにデプロイしています..."

    if ! command -v netlify >/dev/null 2>&1; then
        print_warning "Netlify CLI がインストールされていません"
        print_info "npm install -g netlify-cli でインストールできます"
        return 1
    fi

    # 静的エクスポート
    static_export || {
        print_error "静的エクスポートに失敗しました"
        return 1
    }

    print_info "Netlifyデプロイを開始します..."
    netlify deploy --prod --dir=out

    print_success "Netlifyデプロイが完了しました"
}

# ビルドクリーンアップ
clean_build() {
    print_step "ビルドファイルをクリーンアップしています..."

    local patterns=(".next" "out" "build" "dist")

    for pattern in $patterns; do
        if [[ -d "$pattern" ]]; then
            local size=$(du -sh "$pattern" 2>/dev/null | cut -f1)
            rm -rf "$pattern"
            print_success "$pattern を削除しました (サイズ: $size)"
        fi
    done

    print_success "ビルドクリーンアップが完了しました"
}

# メイン処理
main() {
    local command="$1"
    shift

    local env=""
    local analyze="false"
    local clean="false"
    local verbose="false"
    local dry_run="false"
    local skip_checks="false"

    # オプション解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --env)
                env="$2"
                shift
                ;;
            --analyze)
                analyze="true"
                ;;
            --clean)
                clean="true"
                ;;
            --verbose|-v)
                verbose="true"
                ;;
            --dry-run|-n)
                dry_run="true"
                ;;
            --skip-checks)
                skip_checks="true"
                ;;
            *)
                print_error "不明なオプション: $1"
                return 1
                ;;
        esac
        shift
    done

    # 環境設定
    setup_environment "$env"

    # dry-run モード
    if [[ "$dry_run" == "true" ]]; then
        print_warning "DRY-RUN モード: 実際の操作は行いません"
        echo ""
    fi

    # コマンド実行
    case "$command" in
        "build"|"b")
            if [[ "$skip_checks" != "true" ]]; then
                pre_deploy_check || return 1
            fi
            [[ "$dry_run" != "true" ]] && build_project "$clean" "$analyze" "$verbose"
            ;;
        "preview"|"p")
            [[ "$dry_run" != "true" ]] && preview_build
            ;;
        "docker-build"|"db")
            [[ "$dry_run" != "true" ]] && docker_build "$verbose"
            ;;
        "docker-run"|"dr")
            [[ "$dry_run" != "true" ]] && docker_run
            ;;
        "static"|"s")
            [[ "$dry_run" != "true" ]] && static_export
            ;;
        "check"|"c")
            pre_deploy_check
            ;;
        "bundle-analyze"|"ba")
            bundle_analyze
            ;;
        "lighthouse"|"l")
            [[ "$dry_run" != "true" ]] && lighthouse_test
            ;;
        "deploy-vercel"|"dv")
            [[ "$dry_run" != "true" ]] && deploy_vercel
            ;;
        "deploy-netlify"|"dn")
            [[ "$dry_run" != "true" ]] && deploy_netlify
            ;;
        "clean-build"|"cb")
            [[ "$dry_run" != "true" ]] && clean_build
            ;;
        "help"|""|*)
            show_help
            ;;
    esac
}

# スクリプト実行
main "$@"
