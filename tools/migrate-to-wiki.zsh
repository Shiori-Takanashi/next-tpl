#!/usr/bin/env zsh

# GitHub Wiki 移行スクリプト
# Usage: ./tools/migrate-to-wiki.zsh

set -euo pipefail

# カラー出力関数
print_info() { print -P "%F{blue}ℹ️  $1%f" }
print_success() { print -P "%F{green}✅ $1%f" }
print_warning() { print -P "%F{yellow}⚠️  $1%f" }
print_error() { print -P "%F{red}❌ $1%f" }

# 設定
REPO_OWNER="Shiori-Takanashi"
REPO_NAME="next-tpl"
WIKI_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}.wiki.git"
DOCS_SOURCE="docs/development"
WIKI_TEMP_DIR="/tmp/next-tpl-wiki"

print_info "GitHub Wiki 移行を開始します"

# 現在のディレクトリをプロジェクトルートに
cd "$(dirname "$0")/.."

# 1. 移行対象の確認
if [[ ! -d "$DOCS_SOURCE" ]]; then
    print_error "移行対象ディレクトリが見つかりません: $DOCS_SOURCE"
    exit 1
fi

print_info "移行対象: $(find $DOCS_SOURCE -name "*.md" | wc -l) 個のMarkdownファイル"

# 2. Wikiリポジトリのクローン
print_info "Wikiリポジトリをクローンしています..."
if [[ -d "$WIKI_TEMP_DIR" ]]; then
    rm -rf "$WIKI_TEMP_DIR"
fi

git clone "$WIKI_URL" "$WIKI_TEMP_DIR" 2>/dev/null || {
    print_warning "Wikiが存在しないか、アクセスできません"
    print_info "GitHubでWikiを有効化してください: Settings > Wiki"

    # Wikiディレクトリを初期化
    mkdir -p "$WIKI_TEMP_DIR"
    cd "$WIKI_TEMP_DIR"
    git init
    git remote add origin "$WIKI_URL"

    # 初期Homeページを作成
    cat > Home.md << 'EOF'
# Next.js Learning Template - Development Wiki

このWikiには、Next.js学習テンプレートの詳細な開発記録と技術ドキュメントが含まれています。

## 📋 ドキュメント構成

### プロジェクト基盤
- [[Project Overview|01-project-overview]] - プロジェクトの概要と目的
- [[Docker Environment|02-docker-environment]] - Docker環境の設計と実装
- [[Automation Tools|03-automation-tools]] - セットアップ自動化とツール

### 最新の実装記録
- [[CI Workflow Modularization|24-ci-workflow-modularization]] - GitHub Actions CIワークフローのモジュール化
- [[Development Standards|25-development-standards]] - 開発環境標準化（EditorConfig、Prettier等）

### 完全なドキュメント一覧
- [[Documentation Index|README]] - 全ドキュメントの詳細インデックス

## 🔗 関連リンク

- [メインリポジトリ](https://github.com/Shiori-Takanashi/next-tpl)
- [Issue報告](https://github.com/Shiori-Takanashi/next-tpl/issues)
- [Pull Request](https://github.com/Shiori-Takanashi/next-tpl/pulls)

---
*このWikiは docs/development/ から自動移行されました*
EOF

    git add Home.md
    git commit -m "wiki: 初期Homeページ作成"
    cd - > /dev/null
}

cd "$WIKI_TEMP_DIR"

# 3. ファイル名のWiki形式への変換
convert_filename() {
    local file="$1"
    local basename=$(basename "$file" .md)

    # ファイル名をWiki形式に変換
    # 01-project-overview.md → 01-project-overview.md
    # README.md → README.md (特別扱い)

    echo "${basename}.md"
}

# 4. Wiki内部リンクの変換
convert_internal_links() {
    local file="$1"
    local temp_file="${file}.tmp"

    # Markdown内部リンクをWikiリンクに変換
    sed -E 's|\[([^\]]+)\]\(\./([0-9]+-[^)]+)\.md\)|[[\1\|\2]]|g' "$file" > "$temp_file"
    mv "$temp_file" "$file"
}

# 5. ファイルの移行
print_info "ファイルを移行しています..."
find "../$DOCS_SOURCE" -name "*.md" | while read -r source_file; do
    relative_path=${source_file#../$DOCS_SOURCE/}
    wiki_filename=$(convert_filename "$source_file")

    print_info "移行中: $relative_path → $wiki_filename"

    # ファイルをコピー
    cp "$source_file" "$wiki_filename"

    # 内部リンクを変換
    convert_internal_links "$wiki_filename"

    # Wikiメタデータを追加
    {
        echo "<!-- 移行元: docs/development/$relative_path -->"
        echo "<!-- 移行日: $(date '+%Y-%m-%d') -->"
        echo ""
        cat "$wiki_filename"
    } > "${wiki_filename}.tmp"
    mv "${wiki_filename}.tmp" "$wiki_filename"

    print_success "移行完了: $wiki_filename"
done

# 6. 特別なファイルの処理
print_info "特別なファイルを処理しています..."

# サイドバー作成
cat > _Sidebar.md << 'EOF'
## 📚 ドキュメント

### 基盤
* [[Project Overview|01-project-overview]]
* [[Docker Environment|02-docker-environment]]
* [[Automation Tools|03-automation-tools]]

### 設計・戦略
* [[Documentation Strategy|04-documentation-strategy]]
* [[Testing Strategy|08-testing-strategy]]
* [[Security Practices|09-security-practices]]

### 技術実装
* [[TailwindCSS v4|13-tailwindcss-v4]]
* [[Next.js 16 + React 19|16-nextjs-16-react-19]]
* [[Component System|21-component-system-design]]

### 最新の改善
* [[CI Workflow Modularization|24-ci-workflow-modularization]]
* [[Development Standards|25-development-standards]]

### 運用・デプロイ
* [[Production Deployment|20-production-deployment]]
* [[Tools Extension|23-tools-extension]]

---
[[完全なインデックス|README]]
EOF

# フッター作成
cat > _Footer.md << 'EOF'
---
📖 [全ドキュメント一覧](README) | 🏠 [メインリポジトリ](https://github.com/Shiori-Takanashi/next-tpl) | 🐛 [Issue報告](https://github.com/Shiori-Takanashi/next-tpl/issues)
EOF

# 7. Gitコミット
print_info "変更をコミットしています..."
git add .
git commit -m "wiki: docs/development から自動移行

- $(find . -name "*.md" -not -name "Home.md" -not -name "_*.md" | wc -l) 個のドキュメントを移行
- Wiki内部リンク形式に自動変換
- サイドバーとフッターを追加
- 移行メタデータを各ファイルに追加

移行元: docs/development/ ($(date '+%Y-%m-%d'))"

# 8. Wikiにプッシュ
print_info "Wikiリポジトリにプッシュしています..."
git push origin master || git push origin main

print_success "Wiki移行が完了しました！"
print_info "Wiki URL: https://github.com/${REPO_OWNER}/${REPO_NAME}/wiki"

# 9. 元のdocs/developmentディレクトリのアーカイブ確認
cd - > /dev/null
print_warning "元のdocs/developmentディレクトリを削除しますか？"
print_info "削除前にアーカイブブランチを作成することを推奨します"

read -q "?アーカイブブランチを作成しますか? (y/N): " && {
    echo

    ARCHIVE_BRANCH="archive/docs-development-$(date '+%Y%m%d')"
    print_info "アーカイブブランチを作成: $ARCHIVE_BRANCH"

    git checkout -b "$ARCHIVE_BRANCH"
    git add .
    git commit -m "archive: docs/development をWiki移行前にアーカイブ

このブランチには Wiki 移行前の docs/development/ の完全な履歴が保存されています。

Wiki URL: https://github.com/${REPO_OWNER}/${REPO_NAME}/wiki
移行日: $(date '+%Y-%m-%d %H:%M:%S')"

    git push origin "$ARCHIVE_BRANCH"
    git checkout latest

    print_success "アーカイブブランチを作成しました: $ARCHIVE_BRANCH"
}

echo
read -q "?docs/developmentディレクトリを削除しますか? (y/N): " && {
    echo
    print_info "docs/developmentディレクトリを削除しています..."
    rm -rf docs/development

    # 簡潔なREADME更新
    cat > docs/README.md << 'EOF'
# ドキュメント

## 📖 ユーザー向けドキュメント

- [使用ガイド](tpl/point01.md) - 包括的な使用方法
- [バージョン戦略](tpl/point02.md) - 依存関係とバージョン管理

## 🔧 開発者向けドキュメント

詳細な開発記録と技術ドキュメントは **GitHub Wiki** に移行しました：

**📚 [Next.js Template Wiki](https://github.com/Shiori-Takanashi/next-tpl/wiki)**

### Wiki 主要コンテンツ

- プロジェクト設計と実装記録
- Docker環境とCI/CD詳細
- 技術選択の理由と比較検討
- パフォーマンス最適化とセキュリティ
- 学習カリキュラムと教育戦略

## 🤝 コントリビューション

- [Issue報告](https://github.com/Shiori-Takanashi/next-tpl/issues)
- [Pull Request](https://github.com/Shiori-Takanashi/next-tpl/pulls)
- [セキュリティポリシー](../SECURITY.md)

---
*開発記録は 2025年11月4日にWikiに移行されました*
EOF

    git add .
    git commit -m "docs: development記録をWikiに移行完了

- docs/development/ → GitHub Wiki に移行
- docs/README.md を簡潔に再構成
- アーカイブブランチで履歴を保存

Wiki: https://github.com/${REPO_OWNER}/${REPO_NAME}/wiki"

    print_success "移行処理が完全に完了しました！"
} || {
    echo
    print_info "docs/developmentディレクトリは保持されました"
}

# 10. 一時ディレクトリのクリーンアップ
print_info "一時ファイルをクリーンアップしています..."
rm -rf "$WIKI_TEMP_DIR"

print_success "🎉 GitHub Wiki移行処理が完了しました！"
print_info "Wiki URL: https://github.com/${REPO_OWNER}/${REPO_NAME}/wiki"
