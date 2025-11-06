# GitHub Wiki 自動移行戦略

**作成日**: 2025年11月4日 **目的**: 開発記録の適切な配置とリポジトリ軽量化

## 📋 問題の背景

### 現在の課題

1. **リポジトリサイズの肥大化**
   - `docs/development/` に26個のMarkdownファイル（292KB）
   - 詳細な実装記録がメインコードベースを圧迫
   - 学習者向けテンプレートとしては重すぎる

2. **関心の分離不足**
   - ユーザー向けドキュメント vs 開発者向け記録の混在
   - メインリポジトリの本来の目的（学習テンプレート）が不明確
   - 保守・開発記録がコードと同一視される

3. **アクセシビリティの問題**
   - 深いディレクトリ構造での検索性低下
   - GitHub Wikiの方が閲覧・編集に適している
   - サイドバーやナビゲーションの不足

## 🎯 解決戦略: GitHub Wiki 移行

### GitHub Wiki の利点

1. **関心の分離**
   - コードリポジトリ: 学習者向けのクリーンなテンプレート
   - Wiki: 開発者・保守者向けの詳細記録

2. **優れたUX**
   - サイドバーナビゲーション
   - 全文検索機能
   - Wiki内リンクの自動補完

3. **独立したバージョン管理**
   - Wikiは独立したGitリポジトリ
   - メインコードの履歴を汚さない
   - 個別のアクセス制御可能

4. **軽量化**
   - メインリポジトリから292KBのドキュメントを除去
   - クローン時間の短縮
   - 学習者の負担軽減

## 🔧 移行実装方法

### 1. 手動移行スクリプト

#### `tools/migrate-to-wiki.zsh`

```bash
#!/usr/bin/env zsh
# GitHub Wiki 手動移行スクリプト

set -euo pipefail

# 設定
REPO_OWNER="Shiori-Takanashi"
REPO_NAME="next-tpl"
WIKI_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}.wiki.git"
DOCS_SOURCE="docs/development"
WIKI_TEMP_DIR="/tmp/next-tpl-wiki"

# 1. Wikiリポジトリのクローン/初期化
git clone "$WIKI_URL" "$WIKI_TEMP_DIR" || {
    mkdir -p "$WIKI_TEMP_DIR"
    cd "$WIKI_TEMP_DIR"
    git init
    git remote add origin "$WIKI_URL"
}

# 2. ファイル移行とリンク変換
find "../$DOCS_SOURCE" -name "*.md" | while read -r source_file; do
    wiki_filename=$(basename "$source_file")

    # ファイルコピーとメタデータ追加
    {
        echo "<!-- 移行元: docs/development/$(basename "$source_file") -->"
        echo "<!-- 移行日: $(date '+%Y-%m-%d') -->"
        echo ""
        cat "$source_file"
    } > "$wiki_filename"

    # Wiki内部リンク形式に変換
    sed -i -E 's|\[([^\]]+)\]\(\./([0-9]+-[^)]+)\.md\)|[[\1\|\2]]|g' "$wiki_filename"
done

# 3. Wiki特有ファイル作成
# Home.md, _Sidebar.md, _Footer.md

# 4. コミット・プッシュ
git add .
git commit -m "wiki: docs/development から自動移行"
git push origin master
```

**使用方法**:

```bash
chmod +x tools/migrate-to-wiki.zsh
./tools/migrate-to-wiki.zsh
```

### 2. GitHub Actions 自動同期

#### `.github/workflows/wiki-sync.yml`

```yaml
name: Auto Wiki Sync

on:
  push:
    branches: [main, latest]
    paths:
      - "docs/development/**"
  workflow_dispatch:

jobs:
  sync-to-wiki:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Clone Wiki repository
        run: |
          WIKI_URL="https://github.com/${{ github.repository }}.wiki.git"
          git clone "$WIKI_URL" wiki-repo || {
            mkdir wiki-repo && cd wiki-repo
            git init && git remote add origin "$WIKI_URL"
          }

      - name: Sync documentation
        run: |
          cd wiki-repo
          find ../docs/development -name "*.md" | while read -r file; do
            basename_file=$(basename "$file")
            {
              echo "<!-- Auto-synced: $(date -u '+%Y-%m-%d %H:%M:%S UTC') -->"
              echo "<!-- Source: ${{ github.sha }} -->"
              echo ""
              cat "$file"
            } > "$basename_file"
          done

      - name: Update Wiki metadata
        run: |
          cd wiki-repo
          # _Sidebar.md, _Footer.md の更新
          # タイムスタンプ更新

      - name: Commit and push
        run: |
          cd wiki-repo
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add .
          git commit -m "wiki: Auto-sync from ${{ github.sha }}"
          git push origin master
```

**トリガー条件**:

- `docs/development/` への変更時
- 手動実行（workflow_dispatch）

### 3. メインリポジトリの整理

#### 移行後の構成

```
next-tpl/
├── README.md (簡潔な概要)
├── docs/
│   ├── README.md (Wikiへのリンク)
│   └── tpl/ (ユーザー向けガイド)
├── app/ (実際のコード)
├── components/
└── tools/
```

#### `docs/README.md` の更新

```markdown
# ドキュメント

## 📖 ユーザー向けドキュメント

- [使用ガイド](tpl/point01.md) - 包括的な使用方法
- [バージョン戦略](tpl/point02.md) - 依存関係管理

## 🔧 開発者向けドキュメント

詳細な開発記録は **GitHub Wiki** に移行しました：

**📚
[Next.js Template Wiki](https://github.com/Shiori-Takanashi/next-tpl/wiki)**

### Wiki コンテンツ

- プロジェクト設計・実装記録
- 技術選択の理由と比較検討
- CI/CD・自動化戦略
- パフォーマンス・セキュリティ最適化
- 学習カリキュラム設計

---

_開発記録は 2025年11月4日にWikiに移行_
```

## 📊 Wiki 構成設計

### ページ構造

```
Wiki Home
├── 基盤設計/
│   ├── Project Overview
│   ├── Docker Environment
│   └── Automation Tools
├── 技術実装/
│   ├── TailwindCSS v4
│   ├── Next.js 16 + React 19
│   └── Component System
├── 品質・運用/
│   ├── Testing Strategy
│   ├── Security Practices
│   └── Production Deployment
└── 最新改善/
    ├── CI Workflow Modularization
    └── Development Standards
```

### Wiki特有ファイル

#### `Home.md` - ランディングページ

```markdown
# Next.js Learning Template - Development Wiki

このWikiには、テンプレートの詳細な開発記録が含まれています。

## 📋 主要ドキュメント

- [[Project Overview|01-project-overview]] - 全体設計
- [[CI Workflow Modularization|24-ci-workflow-modularization]] - 最新CI改善
- [[Development Standards|25-development-standards]] - 開発環境統一

## 🔗 関連リンク

- [メインリポジトリ](https://github.com/Shiori-Takanashi/next-tpl)
- [Issue報告](https://github.com/Shiori-Takanashi/next-tpl/issues)

---

_自動同期: GitHub Actions_
```

#### `_Sidebar.md` - ナビゲーション

```markdown
## 📚 ドキュメント

### 基盤・設計

- [[Project Overview|01-project-overview]]
- [[Docker Environment|02-docker-environment]]

### 最新改善

- [[CI Workflow Modularization|24-ci-workflow-modularization]]
- [[Development Standards|25-development-standards]]

---

[[📋 完全一覧|README]]
```

#### `_Footer.md` - 共通フッター

```markdown
📖 [全ドキュメント](README) | 🏠
[メインリポジトリ](https://github.com/Shiori-Takanashi/next-tpl) | 🐛
[Issue](https://github.com/Shiori-Takanashi/next-tpl/issues)
```

## 🔄 移行プロセス

### Phase 1: 準備

1. **GitHub Wikiの有効化**
   - Repository Settings > Wiki にチェック

2. **移行スクリプトの作成**
   - `tools/migrate-to-wiki.zsh`
   - リンク変換ロジック
   - メタデータ追加機能

3. **自動同期ワークフローの準備**
   - `.github/workflows/wiki-sync.yml`

### Phase 2: 移行実行

1. **手動移行の実行**

   ```bash
   ./tools/migrate-to-wiki.zsh
   ```

2. **結果の検証**
   - Wiki pages の動作確認
   - 内部リンクの正常性
   - フォーマットの維持

3. **アーカイブブランチ作成**
   ```bash
   git checkout -b archive/docs-development-20251104
   git push origin archive/docs-development-20251104
   ```

### Phase 3: 後処理

1. **メインリポジトリの整理**

   ```bash
   rm -rf docs/development/
   # docs/README.md の更新
   ```

2. **自動同期の有効化**
   - GitHub Actions ワークフローが動作確認

3. **ドキュメント更新**
   - メインREADME.mdにWikiリンク追加

## 📈 期待効果

### リポジトリ軽量化

| 項目         | 移行前 | 移行後 | 改善    |
| ------------ | ------ | ------ | ------- |
| docs/ サイズ | 292KB  | ~50KB  | 83%削減 |
| ファイル数   | 26個   | 2-3個  | 88%削減 |
| クローン時間 | 長い   | 短縮   | 高速化  |

### UX向上

- **学習者**: クリーンなテンプレートに集中
- **開発者**: Wiki での効率的なナビゲーション
- **保守者**: 独立したドキュメント管理

### 保守性向上

- **自動同期**: 手動更新の負担なし
- **バージョン管理**: Wiki独自の履歴管理
- **アクセス制御**: 必要に応じた編集権限設定

## 🎯 成功基準

### 技術的成功

1. **完全移行**: 全26ファイルがWikiに正常移行
2. **リンク保持**: 内部リンクが[[Wiki Link]]形式で動作
3. **自動同期**: GitHub Actionsが継続的に動作

### UX成功

1. **検索性**: Wiki内全文検索で目的の情報が見つかる
2. **ナビゲーション**: サイドバーで効率的な移動
3. **可読性**: Wiki UI でのドキュメント可読性向上

### プロジェクト成功

1. **軽量化**: メインリポジトリのクローン時間短縮
2. **明確性**: 学習テンプレートとしての目的明確化
3. **保守性**: ドキュメント更新プロセスの自動化

## ⚠️ 注意事項とリスク

### 技術的リスク

1. **Wikiアクセス権限**: 組織やプライベートリポジトリでの制限
2. **自動同期の失敗**: GitHub Actionsの権限やAPI制限
3. **リンク切れ**: 移行時の内部リンク変換ミス

### 運用リスク

1. **ドキュメント分散**: 複数の場所での情報管理
2. **同期ずれ**: 手動編集とGitHubの競合
3. **検索範囲**: メインリポジトリ検索にWikiが含まれない

### 対策

1. **段階的移行**: アーカイブブランチでの安全な保管
2. **テスト環境**: 別リポジトリでの事前検証
3. **ロールバック計画**: 問題時の迅速な復旧手順

## 🔄 今後の運用

### 継続的改善

1. **Wiki構造の最適化**: 利用状況に基づくナビゲーション改善
2. **検索機能強化**: タグ付けやカテゴリ分類
3. **多言語対応**: 英語版Wikiの検討

### 拡張可能性

1. **API活用**: GitHub Wiki APIでの高度な自動化
2. **外部ツール連携**: Notion、Confluenceとの同期
3. **統計・分析**: Wiki利用状況の可視化

---

**結論**: GitHub
Wiki移行は、プロジェクトの目的明確化、UX向上、保守性強化を同時に実現する戦略的な決断です。適切な自動化により、ドキュメント管理の負担を軽減しつつ、各関係者にとって最適なドキュメント体験を提供できます。
