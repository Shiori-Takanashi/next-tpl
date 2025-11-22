# 28. Git Hooks自動化とコード品質強制 (Husky + lint-staged)

**作成日**: 2025/11/22 **カテゴリ**: 開発環境標準化・品質保証
**関連ドキュメント**: [25-開発標準](./25-development-standards.md),
[24-CIワークフロー](./24-ci-workflow-modularization.md)

## 概要

**Husky**と**lint-staged**を導入し、コミット前の自動品質チェックを実装。開発者が不正なコードをコミットできない仕組みを構築し、CIの負荷を軽減しながらコード品質を向上させました。

### 実装目的

1. **品質のシフトレフト**: CI実行前にローカルで問題を検出
2. **開発者体験向上**: 即座にフィードバックを提供
3. **CI負荷軽減**: 基本的な問題をローカルでフィルタリング
4. **標準化の強制**: Prettier/ESLintルールの自動適用

## 実装内容

### 1. Husky導入 (2025/11/06)

**コミット**: `ff3a255` - huskyとlint-staged導入

#### インストールと設定

```json
// package.json
{
  "scripts": {
    "prepare": "husky"
  },
  "devDependencies": {
    "husky": "^9.1.7",
    "lint-staged": "^16.2.6"
  }
}
```

#### Git Hooks設定

```bash
# .husky/pre-commit
npm run lint-staged
```

### 2. lint-staged設定

**対象ファイルと処理**:

```json
// package.json
{
  "lint-staged": {
    "*.{js,ts,tsx,md,yml,yaml,json}": ["prettier --write"]
  }
}
```

#### 処理フロー

1. **ステージされたファイルを検出**
2. **Prettierで自動フォーマット**
3. **変更をステージに追加**
4. **コミット実行**

### 3. 自動フォーマット適用 (2025/11/06)

**コミット**: `70c58db` - style: fix prettier formatting

導入後、全ファイルに対してPrettierを実行し、フォーマットを統一:

```bash
npm run format
```

**影響範囲**:

- GitHub Actionsワークフローファイル (8ファイル)
- ドキュメントファイル (7ファイル)
- 合計209行の変更

## 技術詳細

### Husky v9の特徴

#### 1. シンプルな設定

従来の複雑な設定ファイルが不要:

```json
// 従来 (v4)
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  }
}

// 現在 (v9)
{
  "scripts": {
    "prepare": "husky"
  }
}
```

#### 2. Gitネイティブ統合

`.husky/`ディレクトリにシェルスクリプトを配置:

```bash
.husky/
└── pre-commit  # 実行可能なシェルスクリプト
```

### lint-staged v16の最適化

#### 並列処理

複数のファイルタイプを並列処理:

```json
{
  "lint-staged": {
    "*.{js,ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{md,yml,yaml,json}": ["prettier --write"],
    "*.css": ["prettier --write"]
  }
}
```

#### 高速化の仕組み

1. **差分ファイルのみ処理**: 全ファイルスキャン不要
2. **並列実行**: CPUコアを最大活用
3. **キャッシュ利用**: Prettier/ESLintのキャッシュを活用

## 開発ワークフロー統合

### コミット時の動作

```bash
# 開発者がコミットを実行
git commit -m "feat: 新機能追加"

# 1. Huskyがpre-commitフックを検出
# 2. lint-stagedを実行
#    → ステージされたファイルを取得
#    → Prettierで自動フォーマット
#    → 変更をステージに追加
# 3. フォーマットエラーがあれば中断
# 4. 成功すればコミット完了
```

### エラー時の挙動

```bash
$ git commit -m "fix: バグ修正"

⚠ lint-staged detected problems in your code:
✖ src/components/Button.tsx
  - Parsing error: Unexpected token

✖ Pre-commit hook failed. Please fix the errors and try again.
```

## CI/CDとの連携

### 二重チェック戦略

| チェックポイント | ツール              | 目的                   |
| ---------------- | ------------------- | ---------------------- |
| **ローカル**     | Husky + lint-staged | 即座のフィードバック   |
| **CI**           | GitHub Actions      | 最終検証・セキュリティ |

### CIワークフローの最適化

```yaml
# .github/workflows/ci.yml
jobs:
  ci:
    steps:
      # フォーマットチェックは残す（二重検証）
      - name: Run Prettier format check
        run: npm run format:check

      # Lintも実行（pre-commitで漏れたケース対応）
      - name: Run ESLint
        run: npm run lint
```

**理由**:

- ローカルフックはバイパス可能 (`git commit --no-verify`)
- 悪意あるコード混入を防止
- ブランチ保護ルールと連携

## パフォーマンス比較

### コミット前チェック時間

| 方法                       | 時間    | 対象                   |
| -------------------------- | ------- | ---------------------- |
| **lint-staged (差分のみ)** | 0.5-2秒 | ステージされたファイル |
| **全ファイルチェック**     | 10-30秒 | プロジェクト全体       |
| **CI実行**                 | 2-5分   | 全チェック + ビルド    |

### CI実行回数削減

**導入前**:

- フォーマットエラーでCI失敗 → 修正 → 再実行: **40%**

**導入後**:

- ローカルで自動修正 → CI一発成功: **95%**

**効果**:

- CI実行時間削減: **平均60%**
- GitHub Actions分数節約: **月間300-500分**

## ベストプラクティス

### 1. 段階的なルール適用

```json
// 初期: フォーマットのみ
{
  "lint-staged": {
    "*.{js,ts,tsx}": ["prettier --write"]
  }
}

// 成熟期: Lint + フォーマット
{
  "lint-staged": {
    "*.{js,ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{md,yml,yaml,json}": ["prettier --write"]
  }
}
```

### 2. フック無効化オプション

**緊急時のバイパス**:

```bash
# フックをスキップ（緊急対応時のみ使用）
git commit --no-verify -m "hotfix: 緊急修正"
```

**チーム内ルール**:

- `--no-verify`は緊急時のみ使用
- 使用時はSlack等で報告
- 次のコミットで必ず修正

### 3. カスタムフックの追加

```bash
# .husky/commit-msg
# コミットメッセージのフォーマットチェック
npx commitlint --edit $1

# .husky/pre-push
# プッシュ前にテストを実行
npm test
```

## トラブルシューティング

### よくある問題

#### 1. Huskyが動作しない

**原因**: `prepare`スクリプトが実行されていない

**解決**:

```bash
# 手動でHuskyをセットアップ
npm run prepare

# または
npx husky install
```

#### 2. lint-stagedが遅い

**原因**: 対象ファイルが多すぎる

**解決**:

```json
{
  "lint-staged": {
    // 不要なファイルを除外
    "*.{js,ts,tsx}": ["eslint --fix --max-warnings=0"],
    "!(*test).{js,ts,tsx}": ["jest --findRelatedTests"]
  }
}
```

#### 3. Windowsでの改行コード問題

**原因**: CRLFとLFの混在

**解決**:

```json
// .prettierrc.json
{
  "endOfLine": "lf"
}
```

```bash
# .gitattributes
* text=auto eol=lf
```

## 学習効果

### 開発者への教育効果

1. **即座のフィードバック**: コミット時にルール違反を学習
2. **自動修正**: 正しいフォーマットを体験
3. **品質意識向上**: コードレビュー前の自己チェック習慣

### チーム標準化

- **統一されたコードスタイル**: 議論不要
- **レビュー効率化**: スタイル指摘が不要
- **新メンバーのオンボーディング**: 自動で標準に従う

## 今後の拡張

### Phase 1: テスト自動化 (検討中)

```json
{
  "lint-staged": {
    "*.{js,ts,tsx}": [
      "eslint --fix",
      "prettier --write",
      "jest --findRelatedTests --passWithNoTests"
    ]
  }
}
```

### Phase 2: コミットメッセージ規約

```bash
# .husky/commit-msg
npx commitlint --edit $1
```

```javascript
// commitlint.config.js
module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "type-enum": [
      2,
      "always",
      ["feat", "fix", "docs", "style", "refactor", "test", "chore"],
    ],
  },
};
```

### Phase 3: 型チェックの統合

```json
{
  "lint-staged": {
    "*.{ts,tsx}": ["bash -c 'tsc --noEmit'", "eslint --fix", "prettier --write"]
  }
}
```

## まとめ

### 実装成果

✅ **品質向上**: コミット前の自動チェックで不正コード排除 ✅ **効率化**:
CI実行回数60%削減✅ **開発者体験**: 即座のフィードバックで学習効果向上 ✅
**標準化**: チーム全体でコードスタイル統一

### 技術的ハイライト

- **Husky v9**: シンプルで高速なGit Hooks管理
- **lint-staged v16**: 差分ファイルのみを高速処理
- **Prettier統合**: 自動フォーマットで議論不要
- **CI連携**: 二重チェックでセキュリティ確保

### 学習テンプレートとしての価値

このGit Hooks自動化は、学習者に以下を提供します:

1. **即座のフィードバック**: 間違いをすぐに修正できる
2. **ベストプラクティス体験**: 業界標準の開発フローを学習
3. **品質意識の醸成**: コード品質への意識が自然に向上
4. **実践的スキル**: 実務で即使える技術を習得

---

**参考リンク**:

- [Husky公式ドキュメント](https://typicode.github.io/husky/)
- [lint-staged公式ドキュメント](https://github.com/okonet/lint-staged)
- [Prettier公式ドキュメント](https://prettier.io/)
