#!/usr/bin/env zsh

# Git操作支援ツール - 学習者向けGitワークフロー自動化
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

# ヘルプ表示
show_help() {
    print -P "%F{cyan}🔧 Git操作支援ツール%f"
    echo ""
    echo "使用方法: ./tools/git-helper.zsh [コマンド]"
    echo ""
    echo "📋 利用可能なコマンド:"
    echo ""
    echo "  learn-start [名前]    新しい学習ブランチを作成"
    echo "  learn-save [メッセージ] 学習内容をコミット"
    echo "  learn-reset           mainブランチに戻る"
    echo "  learn-list            学習ブランチ一覧表示"
    echo "  quick-commit [メッセージ] 変更を素早くコミット"
    echo "  status                詳細なステータス表示"
    echo "  sync                  リモートと同期"
    echo "  clean-branches        不要なブランチをクリーンアップ"
    echo "  backup                現在の作業をバックアップ"
    echo ""
    echo "🎓 学習者向け機能:"
    echo "  learn-start component-practice"
    echo "  learn-save \"コンポーネント作成完了\""
    echo "  learn-reset"
}

# 学習ブランチ作成
learn_start() {
    local branch_name="$1"
    
    if [[ -z "$branch_name" ]]; then
        vared -p "学習ブランチ名を入力してください: " -c branch_name
    fi
    
    if [[ -z "$branch_name" ]]; then
        print_error "ブランチ名が指定されていません"
        return 1
    fi
    
    # mainブランチに切り替え
    print_info "mainブランチに切り替えています..."
    git checkout main 2>/dev/null || {
        print_warning "mainブランチが存在しません。現在のブランチから作成します。"
    }
    
    # 新しい学習ブランチ作成
    local full_branch_name="learn/$branch_name"
    print_info "学習ブランチ '$full_branch_name' を作成しています..."
    
    if git checkout -b "$full_branch_name" 2>/dev/null; then
        print_success "学習ブランチ '$full_branch_name' を作成しました"
        print_info "現在のブランチ: $(git branch --show-current)"
        echo ""
        echo "💡 学習のヒント:"
        echo "  - 変更を保存: ./tools/git-helper.zsh learn-save \"メッセージ\""
        echo "  - mainに戻る: ./tools/git-helper.zsh learn-reset"
    else
        print_error "ブランチの作成に失敗しました"
        return 1
    fi
}

# 学習内容保存
learn_save() {
    local message="$1"
    
    if [[ -z "$message" ]]; then
        vared -p "コミットメッセージを入力してください: " -c message
    fi
    
    if [[ -z "$message" ]]; then
        print_error "コミットメッセージが指定されていません"
        return 1
    fi
    
    local current_branch=$(git branch --show-current)
    
    # 学習ブランチかチェック
    if [[ ! "$current_branch" =~ ^learn/ ]]; then
        print_warning "現在のブランチ ($current_branch) は学習ブランチではありません"
        read -q "?続行しますか? (y/N): " && echo || return 1
    fi
    
    print_info "変更をステージングしています..."
    git add -A
    
    # 変更があるかチェック
    if git diff --cached --quiet; then
        print_warning "コミットする変更がありません"
        return 0
    fi
    
    print_info "学習内容をコミットしています..."
    local full_message="🎓 学習記録: $message"
    
    if git commit -m "$full_message"; then
        print_success "学習内容を保存しました"
        print_info "ブランチ: $current_branch"
        print_info "メッセージ: $full_message"
    else
        print_error "コミットに失敗しました"
        return 1
    fi
}

# 学習環境リセット
learn_reset() {
    local current_branch=$(git branch --show-current)
    
    print_info "学習環境をリセットしています..."
    
    # 未保存の変更をチェック
    if ! git diff --quiet || ! git diff --cached --quiet; then
        print_warning "未保存の変更があります"
        echo "変更ファイル:"
        git status --porcelain
        echo ""
        read -q "?変更を破棄してmainブランチに戻りますか? (y/N): " && echo || return 1
        git reset --hard HEAD
    fi
    
    # mainブランチに切り替え
    print_info "mainブランチに切り替えています..."
    if git checkout main; then
        print_success "mainブランチに戻りました"
        
        # 学習ブランチの削除を提案
        if [[ "$current_branch" =~ ^learn/ ]]; then
            echo ""
            read -q "?学習ブランチ '$current_branch' を削除しますか? (y/N): " && {
                echo
                git branch -D "$current_branch" 2>/dev/null && {
                    print_success "学習ブランチ '$current_branch' を削除しました"
                } || {
                    print_warning "ブランチの削除に失敗しました"
                }
            } || echo
        fi
    else
        print_error "mainブランチへの切り替えに失敗しました"
        return 1
    fi
}

# 学習ブランチ一覧
learn_list() {
    print_info "学習ブランチ一覧:"
    echo ""
    
    local learn_branches=($(git branch | grep "learn/" | sed 's/^[* ] //' | sed 's/^learn\///'))
    
    if [[ ${#learn_branches[@]} -eq 0 ]]; then
        print_warning "学習ブランチが見つかりません"
        echo ""
        echo "💡 新しい学習ブランチを作成:"
        echo "  ./tools/git-helper.zsh learn-start <ブランチ名>"
        return 0
    fi
    
    local current_branch=$(git branch --show-current)
    
    for branch in $learn_branches; do
        local full_branch="learn/$branch"
        if [[ "$current_branch" == "$full_branch" ]]; then
            print -P "%F{green}  ▶ $branch (現在)%f"
        else
            echo "    $branch"
        fi
        
        # 最後のコミット情報
        local last_commit=$(git log -1 --format="%h %s" "$full_branch" 2>/dev/null || echo "コミットなし")
        echo "      └─ $last_commit"
    done
}

# クイックコミット
quick_commit() {
    local message="$1"
    
    if [[ -z "$message" ]]; then
        vared -p "コミットメッセージを入力してください: " -c message
    fi
    
    if [[ -z "$message" ]]; then
        print_error "コミットメッセージが指定されていません"
        return 1
    fi
    
    print_info "変更をステージングしています..."
    git add -A
    
    if git diff --cached --quiet; then
        print_warning "コミットする変更がありません"
        return 0
    fi
    
    print_info "変更をコミットしています..."
    if git commit -m "$message"; then
        print_success "変更をコミットしました: $message"
    else
        print_error "コミットに失敗しました"
        return 1
    fi
}

# 詳細ステータス
detailed_status() {
    print_info "詳細なGitステータス"
    echo ""
    
    # 現在のブランチ
    local current_branch=$(git branch --show-current)
    print -P "%F{cyan}📍 現在のブランチ: %F{yellow}$current_branch%f"
    
    # 変更状況
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo ""
        print -P "%F{yellow}📝 変更ファイル:%f"
        git status --porcelain | while read -r line; do
            local status=${line:0:2}
            local file=${line:3}
            case "$status" in
                "M ") echo "  🔄 修正: $file" ;;
                "A ") echo "  ➕ 追加: $file" ;;
                "D ") echo "  ➖ 削除: $file" ;;
                "??") echo "  ❓ 未追跡: $file" ;;
                *) echo "  $status $file" ;;
            esac
        done
    else
        echo ""
        print_success "作業ディレクトリはクリーンです"
    fi
    
    # 最近のコミット
    echo ""
    print_info "最近のコミット (5件):"
    git log --oneline -5 --color=always | while read -r line; do
        echo "  $line"
    done
    
    # ブランチ情報
    echo ""
    print_info "ローカルブランチ:"
    git branch | while read -r line; do
        if [[ "$line" =~ ^\* ]]; then
            print -P "  %F{green}$line%f"
        else
            echo "  $line"
        fi
    done
}

# リモート同期
sync_remote() {
    print_info "リモートリポジトリと同期しています..."
    
    # リモートが設定されているかチェック
    if ! git remote | grep -q origin; then
        print_warning "リモートリポジトリ 'origin' が設定されていません"
        return 0
    fi
    
    # フェッチ
    print_info "リモートから最新情報を取得しています..."
    if git fetch origin; then
        print_success "リモート情報を取得しました"
        
        # mainブランチの更新チェック
        local behind=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")
        if [[ "$behind" -gt 0 ]]; then
            print_warning "mainブランチが $behind コミット遅れています"
            read -q "?mainブランチを更新しますか? (y/N): " && {
                echo
                git checkout main && git pull origin main
                print_success "mainブランチを更新しました"
            } || echo
        fi
    else
        print_error "リモート同期に失敗しました"
        return 1
    fi
}

# 不要ブランチクリーンアップ
clean_branches() {
    print_info "不要なブランチをクリーンアップしています..."
    
    # マージ済みブランチの検索
    local merged_branches=($(git branch --merged | grep -v "main\|master\|\*" | tr -d ' '))
    
    if [[ ${#merged_branches[@]} -eq 0 ]]; then
        print_success "クリーンアップが必要なブランチはありません"
        return 0
    fi
    
    echo ""
    echo "削除対象ブランチ:"
    for branch in $merged_branches; do
        echo "  - $branch"
    done
    
    echo ""
    read -q "?これらのブランチを削除しますか? (y/N): " && {
        echo
        for branch in $merged_branches; do
            if git branch -d "$branch" 2>/dev/null; then
                print_success "ブランチ '$branch' を削除しました"
            else
                print_warning "ブランチ '$branch' の削除に失敗しました"
            fi
        done
    } || echo
}

# 作業バックアップ
backup_work() {
    local timestamp=$(date +"%Y%m%d-%H%M%S")
    local current_branch=$(git branch --show-current)
    local backup_branch="backup/${current_branch}-${timestamp}"
    
    print_info "現在の作業をバックアップしています..."
    
    # 未追跡ファイルも含めてステージング
    git add -A
    
    if git diff --cached --quiet; then
        print_warning "バックアップする変更がありません"
        return 0
    fi
    
    # 一時コミット作成
    git commit -m "🔄 一時保存 (${timestamp})"
    
    # バックアップブランチ作成
    if git checkout -b "$backup_branch"; then
        print_success "バックアップブランチ '$backup_branch' を作成しました"
        
        # 元のブランチに戻る
        git checkout "$current_branch"
        
        # 最新コミットを取り消し（変更は残る）
        git reset HEAD~1
        
        print_info "元のブランチに戻りました"
        print_info "バックアップ: $backup_branch"
    else
        print_error "バックアップの作成に失敗しました"
        return 1
    fi
}

# メイン処理
main() {
    case "$1" in
        "learn-start"|"ls")
            learn_start "$2"
            ;;
        "learn-save"|"save")
            learn_save "$2"
            ;;
        "learn-reset"|"reset")
            learn_reset
            ;;
        "learn-list"|"list")
            learn_list
            ;;
        "quick-commit"|"qc")
            quick_commit "$2"
            ;;
        "status"|"st")
            detailed_status
            ;;
        "sync")
            sync_remote
            ;;
        "clean-branches"|"clean")
            clean_branches
            ;;
        "backup")
            backup_work
            ;;
        "help"|""|*)
            show_help
            ;;
    esac
}

# スクリプト実行
main "$@"