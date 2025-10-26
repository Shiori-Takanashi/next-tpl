/**
 * ESLint設定ファイル
 * Next.js学習テンプレート用
 *
 * 学習者向けに基本的なルールのみを設定
 * より厳密なルールは学習が進んでから追加できます
 */
import { defineConfig } from "eslint/config";
import next from "eslint-config-next";

const eslintConfig = defineConfig([
  // Next.js推奨設定を適用
  ...next,

  // 基本ルール設定
  {
    rules: {
      // 学習段階では警告レベルに設定
      "@typescript-eslint/no-unused-vars": "warn",
      "@typescript-eslint/no-explicit-any": "warn",

      // 学習に役立つルール
      "no-console": "warn", // console.logの使用を警告
      "prefer-const": "error", // constを使える場合は使用を強制
    }
  },

  // 無視するファイル・ディレクトリ
  {
    ignores: [
      ".next/**",
      "out/**",
      "build/**",
      "next-env.d.ts",
      "node_modules/**"
    ]
  }
]);

export default eslintConfig;
