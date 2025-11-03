/**
 * ESLint設定ファイル
 * Next.js学習テンプレート用（日本語最適化済み）
 *
 * 学習者向けに基本的なルールのみを設定
 * より厳密なルールは学習が進んでから追加できます
 */
import js from "@eslint/js";
import next from "eslint-config-next";

const eslintConfig = [
  // JavaScript推奨設定
  js.configs.recommended,

  // Next.js推奨設定
  ...next,

  // 基本ルール設定
  {
    languageOptions: {
      globals: {
        React: "readonly",
        JSX: "readonly",
      },
    },
    rules: {
      // 学習段階では警告レベルに設定
      "no-unused-vars": "warn",
      "no-undef": "error",

      // 学習に役立つルール
      "no-console": "warn", // console.logの使用を警告
      "prefer-const": "error", // constを使える場合は使用を強制

      // React/Next.js固有
      "react/no-unescaped-entities": "warn",
      "react-hooks/exhaustive-deps": "warn",
      "react/react-in-jsx-scope": "off", // React 19の新しいJSX変換対応
    }
  },

  // 無視するファイル・ディレクトリ
  {
    ignores: [
      ".next/**",
      "out/**",
      "build/**",
      "next-env.d.ts",
      "node_modules/**",
      "*.config.js",
      "*.config.mjs",
      "*.config.ts"
    ]
  }
];

export default eslintConfig;
