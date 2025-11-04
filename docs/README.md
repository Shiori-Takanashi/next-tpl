# ドキュメント

## 📖 ユーザー向けドキュメント

- [使用ガイド](tpl/point01.md) - 包括的な使用方法
- [バージョン戦略](tpl/point02.md) - 依存関係とバージョン管理

## 🔧 開発者向けドキュメント

**⚠️ 重要**: 詳細な開発記録は **GitHub Wiki** に移行予定です。

現在 `docs/development/` には26個の詳細な実装記録（292KB）がありますが、
これらはプロジェクトの軽量化のために **GitHub Wiki** への移行を計画しています。

### 移行対象ドキュメント

以下のドキュメントは Wiki 移行対象です：

#### 基盤・設計記録
- プロジェクト概要と目的
- Docker環境設計
- 自動化ツール実装
- ドキュメント戦略

#### 技術実装記録
- TailwindCSS v4対応
- Next.js 16 + React 19実装
- TypeScript設定最適化
- VS Code統合環境

#### 品質・運用記録
- テスト戦略とCI/CD
- セキュリティ実装
- パフォーマンス最適化
- プロダクション環境構築

#### 最新の改善記録
- **CI ワークフローモジュール化** - GitHub Actions の再利用可能ワークフロー分割
- **開発環境標準化** - EditorConfig、Prettier、GitHub管理テンプレート統合
- **Wiki移行戦略** - ドキュメント管理の自動化と軽量化

### Wiki移行の利点

1. **リポジトリ軽量化**: 292KB → 約50KB（83%削減）
2. **関心の分離**: 学習テンプレート vs 開発記録
3. **優れたUX**: サイドバーナビゲーション、全文検索
4. **自動同期**: GitHub Actions による継続的更新

### 移行実行

Wiki移行は以下のツールで実行できます：

```bash
# 手動移行
./tools/migrate-to-wiki.zsh

# 自動同期（GitHub Actions）
# docs/development/ への変更時に自動実行
```

詳細は [Wiki移行戦略](development/26-github-wiki-migration-strategy.md) を参照してください。

## 📋 現在のドキュメント一覧

### development/ ディレクトリ（Wiki移行予定）

| ファイル | 内容 | 移行先 |
|---------|------|--------|
| 01-project-overview.md | プロジェクト全体設計 | Wiki |
| 02-docker-environment.md | Docker環境実装 | Wiki |
| 03-automation-tools.md | 自動化ツール | Wiki |
| ... | (全26ファイル) | Wiki |
| 24-ci-workflow-modularization.md | CI改善記録 | Wiki |
| 25-development-standards.md | 開発標準化 | Wiki |
| 26-github-wiki-migration-strategy.md | 移行戦略 | Wiki |

### tpl/ ディレクトリ（保持）

| ファイル | 内容 | 状態 |
|---------|------|------|
| point01.md | ユーザー使用ガイド | 保持 |
| point02.md | バージョン戦略 | 保持 |

## 🤝 コントリビューション

- [Issue報告](https://github.com/Shiori-Takanashi/next-tpl/issues)
- [Pull Request](https://github.com/Shiori-Takanashi/next-tpl/pulls)
- [セキュリティポリシー](../SECURITY.md)

---

**📅 移行スケジュール**: 2025年11月中に Wiki 移行を実行予定  
**📊 効果**: リポジトリサイズ83%削減、学習者向けUI改善

*この整理により、学習テンプレートとしての本来の目的がより明確になります。*