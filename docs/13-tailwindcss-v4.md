# TailwindCSS v4 実装記録

## 概要

TailwindCSS v4への移行と最新機能活用の実装記録

## TailwindCSS v4 新機能活用

### CSS-first Configuration

```typescript
// tailwind.config.ts
import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      // CSS変数との統合
      colors: {
        background: "rgb(var(--color-background) / <alpha-value>)",
        foreground: "rgb(var(--color-foreground) / <alpha-value>)",
      },
    },
  },
};
```

### インライン@theme使用

```css
@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --font-sans: var(--font-noto-sans-jp), system-ui, sans-serif;
}
```

## カスタムデザインシステム

### カラートークン設計

```css
:root {
  /* 意味的カラー名 */
  --background: #ffffff;
  --foreground: #1a1a1a;
  --primary: #3b82f6;
  --secondary: #f1f5f9;
  --muted: #f8fafc;
  --border: #e2e8f0;
}

@media (prefers-color-scheme: dark) {
  :root {
    --background: #0a0a0a;
    --foreground: #fafafa;
    --primary: #3b82f6;
    --secondary: #1e293b;
    --muted: #1e293b;
    --border: #334155;
  }
}
```

### アルファ値対応カラーシステム

```css
/* TailwindCSS v4の新機能活用 */
.bg-background {
  background: rgb(var(--color-background) / <alpha-value>);
}
.text-primary {
  color: rgb(var(--color-primary) / <alpha-value>);
}
.border-border {
  border-color: rgb(var(--color-border) / <alpha-value>);
}
```

## アニメーションシステム

### キーフレーム定義

```css
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateX(-10px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}
```

### Tailwind統合アニメーション

```typescript
// tailwind.config.ts
animation: {
  "fade-in": "fadeIn 0.5s ease-out",
  "slide-in": "slideIn 0.3s ease-out",
  "pulse-subtle": "pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite",
}
```

## ユーティリティクラス拡張

### カスタムフォント設定

```typescript
fontFamily: {
  sans: ["var(--font-noto-sans-jp)", "sans-serif"],
  mono: ["var(--font-jetbrains-mono)", "monospace"],
  ja: ["var(--font-noto-sans-jp)", "sans-serif"],
}
```

### カスタム角丸設定

```typescript
borderRadius: {
  lg: "var(--radius)",
  md: "calc(var(--radius) - 2px)",
  sm: "calc(var(--radius) - 4px)",
}
```

## グラスモーフィズム実装

### CSS実装

```css
.glass {
  backdrop-filter: blur(10px);
  background: rgb(var(--background) / 0.8);
  border: 1px solid rgb(var(--border) / 0.5);
}
```

### Tailwind統合

```typescript
// 将来的な拡張候補
backdropBlur: {
  xs: "2px",
}
```

## PostCSS統合

### 設定ファイル

```javascript
// postcss.config.mjs
const config = {
  plugins: {
    "@tailwindcss/postcss": {},
  },
};

export default config;
```

### CSS import

```css
/* globals.css */
@import "tailwindcss";
```

## パフォーマンス最適化

### Purging戦略

- 本番環境での未使用CSS除去
- コンテンツパス最適化
- 動的クラス名の適切なパターン指定

### バンドルサイズ最適化

```typescript
// 必要な機能のみインクルード
content: [
  "./app/**/*.{js,ts,jsx,tsx,mdx}",
  // 具体的なパス指定で精度向上
];
```

## デバッグとメンテナンス

### 開発時のデバッグ

- ブラウザ開発者ツールでのCSS変数確認
- Tailwind IntelliSenseとの連携
- カスタムクラス補完設定

### 設定ファイル管理

```typescript
// 型安全な設定
import type { Config } from "tailwindcss";

// 明示的な型注釈
const config: Config = {
  // 設定内容
};

export default config;
```

## ベストプラクティス

### クラス命名規則

- セマンティックな意味を持つクラス名
- 汎用的すぎない具体性
- コンポーネント境界での責任分離

### CSS変数活用

- テーマ切り替え対応
- ランタイムでの動的変更可能性
- JavaScript連携の考慮

## 移行時の注意点

### TailwindCSS v3からの違い

- 設定ファイル構造の変更
- 新しいCSS-first アプローチ
- プラグインシステムの進化

### 互換性確保

- 既存クラス名の維持
- 段階的移行戦略
- フォールバック考慮

## 今後の拡張予定

### コンポーネントライブラリ

- 再利用可能コンポーネント作成
- Storybook統合
- デザインシステム文書化

### 高度なカスタマイゼーション

- 独自Utilityクラス作成
- プラグイン開発
- テーマバリエーション拡張

---

**作成**: 2025/10/27 **更新**: TailwindCSS v4実装完了時 **参考**:
[TailwindCSS v4 Docs](https://tailwindcss.com/docs)
