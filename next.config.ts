import type { NextConfig } from "next";

const isDevelopment = process.env.NODE_ENV === "development";
const isProduction = process.env.NODE_ENV === "production";

const nextConfig: NextConfig = {
  // 画像最適化設定
  images: {
    formats: ["image/webp", "image/avif"],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    // 開発環境では最適化を軽量化
    ...(isDevelopment && {
      unoptimized: false,
      minimumCacheTTL: 60,
    }),
    // 本番環境では最適化を強化
    ...(isProduction && {
      minimumCacheTTL: 31536000, // 1年
    }),
  },

  // セキュリティヘッダー
  async headers() {
    const headers = [
      {
        key: "X-Frame-Options",
        value: "DENY",
      },
      {
        key: "X-Content-Type-Options",
        value: "nosniff",
      },
      {
        key: "Referrer-Policy",
        value: "strict-origin-when-cross-origin",
      },
    ];

    // 本番環境でのみ厳格なセキュリティヘッダーを追加
    if (isProduction) {
      headers.push(
        {
          key: "Strict-Transport-Security",
          value: "max-age=31536000; includeSubDomains; preload",
        },
        {
          key: "Content-Security-Policy",
          value: [
            "default-src 'self'",
            "script-src 'self' 'unsafe-eval' 'unsafe-inline'",
            "style-src 'self' 'unsafe-inline'",
            "img-src 'self' data: https:",
            "font-src 'self'",
            "connect-src 'self'",
          ].join("; "),
        }
      );
    }

    return [
      {
        source: "/(.*)",
        headers,
      },
    ];
  },

  // パフォーマンス最適化
  poweredByHeader: false,
  compress: true,

  // 開発環境固有の設定
  ...(isDevelopment && {
    // 開発時はソースマップを有効化
    experimental: {
      serverComponentsExternalPackages: [],
    },
  }),

  // 本番環境固有の設定
  ...(isProduction && {
    // 本番環境での最適化
    swcMinify: true,
    reactStrictMode: true,
    // 出力設定
    output: "standalone",
  }),
};

export default nextConfig;
