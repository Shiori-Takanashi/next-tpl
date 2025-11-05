# VS Code統合開発環境構築記録

## 概要

学習効率最大化のためのVS Code開発環境構築の詳細記録

## VS Code設定ファイル

### 基本設定 (.vscode/settings.json)

```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "emmet.includeLanguages": {
    "typescript": "typescriptreact",
    "javascript": "javascriptreact"
  },
  "files.associations": {
    "*.css": "tailwindcss"
  },
  "editor.quickSuggestions": {
    "strings": "on"
  },
  "css.validate": false,
  "less.validate": false,
  "scss.validate": false
}
```

### 推奨拡張機能 (.vscode/extensions.json)

```json
{
  "recommendations": [
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "ms-vscode.vscode-typescript-next",
    "formulahendry.auto-rename-tag",
    "christian-kohler.path-intellisense",
    "ms-vscode.vscode-json"
  ]
}
```

## タスク自動化設定

### ビルドタスク (.vscode/tasks.json)

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Next.js開発サーバー起動",
      "type": "shell",
      "command": "npm",
      "args": ["run", "dev"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "new"
      },
      "isBackground": true,
      "problemMatcher": []
    },
    {
      "label": "型チェック実行",
      "type": "shell",
      "command": "npm",
      "args": ["run", "type-check"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always"
      }
    },
    {
      "label": "ESLint実行",
      "type": "shell",
      "command": "npm",
      "args": ["run", "lint"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always"
      }
    },
    {
      "label": "Docker開発環境起動",
      "type": "shell",
      "command": "make",
      "args": ["dev-docker"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "panel": "new"
      },
      "isBackground": true
    }
  ]
}
```

### デバッグ設定 (.vscode/launch.json)

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Next.js デバッグ起動",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/node_modules/next/dist/bin/next",
      "args": ["dev"],
      "cwd": "${workspaceFolder}",
      "env": {
        "NODE_OPTIONS": "--inspect"
      },
      "console": "integratedTerminal",
      "runtimeExecutable": "node",
      "skipFiles": ["<node_internals>/**"]
    },
    {
      "name": "Chrome でデバッグ",
      "type": "chrome",
      "request": "launch",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}"
    }
  ]
}
```

## 開発効率化設定

### TailwindCSS IntelliSense最適化

```json
// settings.json内
"tailwindCSS.includeLanguages": {
  "typescript": "typescript",
  "typescriptreact": "typescriptreact"
},
"tailwindCSS.experimental.classRegex": [
  "tw`([^`]*)`",
  ["clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)"]
]
```

### TypeScript最適化

```json
"typescript.suggest.autoImports": true,
"typescript.updateImportsOnFileMove.enabled": "always",
"typescript.preferences.includePackageJsonAutoImports": "on"
```

## ワークスペース設定

### マルチルート対応

```json
// .vscode/settings.json
"search.exclude": {
  "**/node_modules": true,
  "**/.next": true,
  "**/build": true,
  "**/out": true
}
```

### ファイル監視最適化

```json
"files.watcherExclude": {
  "**/.git/objects/**": true,
  "**/.git/subtree-cache/**": true,
  "**/node_modules/**": true,
  "**/.next/**": true
}
```

## 学習支援機能

### インライン型ヒント

```json
"typescript.inlayHints.parameterNames.enabled": "literals",
"typescript.inlayHints.parameterTypes.enabled": true,
"typescript.inlayHints.variableTypes.enabled": true,
"typescript.inlayHints.propertyDeclarationTypes.enabled": true,
"typescript.inlayHints.functionLikeReturnTypes.enabled": true
```

### エラー表示最適化

```json
"problems.decorations.enabled": true,
"problems.showCurrentInStatus": true,
"typescript.reportStyleChecksAsWarnings": true
```

## Git統合設定

### Git操作最適化

```json
"git.autofetch": true,
"git.confirmSync": false,
"git.enableSmartCommit": true,
"git.postCommitCommand": "none"
```

### 差分表示設定

```json
"diffEditor.ignoreTrimWhitespace": false,
"diffEditor.renderSideBySide": true,
"scm.diffDecorationsGutterVisibility": "always"
```

## パフォーマンス最適化

### 起動時間短縮

```json
"extensions.autoCheckUpdates": false,
"telemetry.telemetryLevel": "off",
"workbench.startupEditor": "none"
```

### メモリ使用量最適化

```json
"typescript.tsc.autoDetect": "on",
"typescript.preferences.disableSuggestions": false,
"typescript.suggest.enabled": true
```

## デバッグ環境

### ブレークポイント設定

- React コンポーネント内
- Next.js API ルート
- カスタムフック内

### ホットリロード最適化

```json
"typescript.preferences.includePackageJsonAutoImports": "on",
"javascript.preferences.includePackageJsonAutoImports": "on"
```

## 拡張機能活用

### 必須拡張機能

1. **TailwindCSS IntelliSense**: クラス補完
2. **ES7+ React/Redux/React-Native snippets**: React スニペット
3. **Auto Rename Tag**: HTMLタグ自動リネーム
4. **Bracket Pair Colorizer**: 括弧色分け

### 学習支援拡張機能

1. **Error Lens**: インラインエラー表示
2. **Thunder Client**: API テスト
3. **Git Graph**: Git履歴可視化
4. **Todo Tree**: TODOコメント管理

## キーボードショートカット

### カスタムショートカット

```json
// keybindings.json
[
  {
    "key": "ctrl+shift+t",
    "command": "workbench.action.tasks.runTask",
    "args": "Next.js開発サーバー起動"
  },
  {
    "key": "ctrl+shift+d",
    "command": "workbench.action.tasks.runTask",
    "args": "Docker開発環境起動"
  }
]
```

## 今後の改善予定

### 追加設定

- Prettier統合最適化
- Husky pre-commit hook設定
- テスト環境統合

### 学習効率化

- コードスニペット拡充
- Live Share設定
- Remote Development対応

---

**作成**: 2025/10/27 **更新**: VS Code統合完了時 **対象**:
Next.js学習者向け最適化環境
