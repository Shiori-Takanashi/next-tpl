# GitHub Actions ワークフロー

このディレクトリには、プロジェクトの自動化ワークフローが含まれています。

## 📁 ディレクトリ構造

```
workflows/
├── ci/          # 継続的インテグレーション
├── deploy/      # デプロイメント
└── wiki/        # Wiki同期
```

## 🔄 CI (継続的インテグレーション)

**ディレクトリ**: `ci/`

プルリクエストとプッシュ時に自動実行される品質チェックワークフロー。

### ワークフロー一覧

- **`main.yml`**: メインCI統合ワークフロー
  - 各CIジョブを統合的に実行
  - トリガー: プッシュ、プルリクエスト

- **`ci-setup.yml`**: 環境セットアップ
  - Node.js環境のセットアップ
  - 依存関係のキャッシュ管理

- **`ci-lint.yml`**: コード品質チェック
  - ESLintによる静的解析
  - コードスタイルの検証

- **`ci-type-check.yml`**: 型チェック
  - TypeScriptの型検証
  - 型安全性の確保

- **`ci-build.yml`**: ビルド検証
  - Next.jsアプリケーションのビルド
  - ビルドエラーの早期検出

- **`ci-security.yml`**: セキュリティスキャン
  - 依存関係の脆弱性チェック
  - `npm audit`の実行

## 🚀 Deploy (デプロイメント)

**ディレクトリ**: `deploy/`

本番環境へのデプロイを管理するワークフロー。

### ワークフロー一覧

- **`main.yml`**: メインデプロイワークフロー
  - Vercelへの自動デプロイ
  - トリガー: `main`ブランチへのプッシュ、手動実行

## 📚 Wiki (ドキュメント同期)

**ディレクトリ**: `wiki/`

ドキュメントをGitHub Wikiに自動同期するワークフロー。

### ワークフロー一覧

- **`sync.yml`**: Wiki自動同期
  - `docs/development/`の内容をWikiに同期
  - トリガー: `docs/development/**`の変更、手動実行
  - 機能:
    - 28個のMarkdownファイルを自動アップロード
    - Wikiサイドバー・フッターの自動生成
    - 同期メタデータの追加

## 🔧 使用方法

### 手動実行

各ワークフローは手動でも実行できます：

1. GitHubリポジトリの「Actions」タブを開く
2. 実行したいワークフローを選択
3. 「Run workflow」ボタンをクリック

### トリガー条件

- **CI**: プッシュ・プルリクエスト時に自動実行
- **Deploy**: `main`ブランチへのプッシュで自動実行
- **Wiki**: `docs/development/`配下のファイル変更で自動実行

## 📊 ワークフロー依存関係

```
CI Workflows (並列実行)
├── Setup → Lint
├── Setup → Type Check
├── Setup → Build
└── Setup → Security

Deploy Workflow
└── 独立実行 (mainブランチのみ)

Wiki Workflow
└── 独立実行 (docs変更時)
```

## 🎯 ベストプラクティス

1. **責任の分離**: 各ワークフローは単一の責任を持つ
2. **並列実行**: CIジョブは可能な限り並列化
3. **早期失敗**: エラーは早期に検出・報告
4. **キャッシュ活用**: 依存関係をキャッシュして高速化
5. **詳細ログ**: デバッグ情報を豊富に出力

## 🔗 関連ドキュメント

- [24-ci-workflow-modularization.md](../../docs/development/24-ci-workflow-modularization.md) - CIワークフローのモジュール化
- [27-github-actions-workflow-separation.md](../../docs/development/27-github-actions-workflow-separation.md) - ワークフロー責任分離

---

*最終更新: 2025-11-05*
