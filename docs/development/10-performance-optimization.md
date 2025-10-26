# 10. パフォーマンス最適化ガイド

**作成日**: 2025-10-26
**目的**: Next.js学習テンプレートにおけるパフォーマンス最適化戦略と実装

## ⚡ パフォーマンス最適化の基本方針

### Core Web Vitals を中心とした最適化

#### 1. Largest Contentful Paint (LCP) - 2.5秒以内
- 画像最適化とレスポンシブ配信
- フォント読み込み最適化
- サーバーレスポンス時間短縮

#### 2. First Input Delay (FID) - 100ms以内
- JavaScript実行時間の最適化
- イベントハンドラーの効率化
- メインスレッドブロッキング回避

#### 3. Cumulative Layout Shift (CLS) - 0.1以下
- 画像・動画のサイズ指定
- 動的コンテンツの領域確保
- フォント表示安定化

## 🖼️ 画像最適化戦略

### Next.js Image コンポーネント活用

#### 1. 基本実装
```jsx
// components/OptimizedImage.tsx
import Image from 'next/image';
import { useState } from 'react';

interface OptimizedImageProps {
  src: string;
  alt: string;
  width?: number;
  height?: number;
  priority?: boolean;
  className?: string;
}

export function OptimizedImage({
  src,
  alt,
  width = 800,
  height = 600,
  priority = false,
  className = ''
}: OptimizedImageProps) {
  const [isLoading, setLoading] = useState(true);

  return (
    <div className={`relative overflow-hidden ${className}`}>
      <Image
        src={src}
        alt={alt}
        width={width}
        height={height}
        priority={priority}
        placeholder="blur"
        blurDataURL="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAhEAACAQMDBQAAAAAAAAAAAAABAgMABAUGIWGRkqGx0f/EABUBAQEAAAAAAAAAAAAAAAAAAAMF/8QAGhEAAgIDAAAAAAAAAAAAAAAAAAECEgMRkf/aAAwDAQACEQMRAD8AltJagyeH0AthI5xdrLcNM91BF5pX2HaH9bcfaSXWGaRmknyJckliyjqTzSlT54b6bk+h0R+Wjn3WGvNFf9k="
        className={`duration-700 ease-in-out ${
          isLoading
            ? 'scale-110 blur-2xl grayscale'
            : 'scale-100 blur-0 grayscale-0'
        }`}
        onLoad={() => setLoading(false)}
      />
    </div>
  );
}
```

#### 2. レスポンシブ画像設定
```javascript
// next.config.js
const nextConfig = {
  images: {
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    formats: ['image/webp'],
    dangerouslyAllowSVG: true,
    contentSecurityPolicy: "default-src 'self'; script-src 'none'; sandbox;",
  }
};
```

### 3. 画像圧縮とフォーマット最適化

#### 自動画像最適化
```bash
# 画像最適化スクリプト
npm install --save-dev imagemin imagemin-webp imagemin-mozjpeg imagemin-pngquant

# scripts/optimize-images.js
const imagemin = require('imagemin');
const imageminWebp = require('imagemin-webp');
const imageminMozjpeg = require('imagemin-mozjpeg');
const imageminPngquant = require('imagemin-pngquant');

(async () => {
  await imagemin(['public/images/*.{jpg,png}'], {
    destination: 'public/images/optimized',
    plugins: [
      imageminMozjpeg({ quality: 80 }),
      imageminPngquant({ quality: [0.6, 0.8] }),
      imageminWebp({ quality: 80 })
    ]
  });

  console.log('Images optimized!');
})();
```

## 📦 JavaScript バンドル最適化

### 1. 動的インポートとCode Splitting

#### ページレベル分割
```jsx
// pages/dashboard.tsx
import dynamic from 'next/dynamic';
import { Suspense } from 'react';

// 重いコンポーネントの遅延読み込み
const HeavyChart = dynamic(() => import('../components/HeavyChart'), {
  loading: () => <div>Loading chart...</div>,
  ssr: false
});

const AdminPanel = dynamic(() => import('../components/AdminPanel'), {
  loading: () => <div>Loading admin panel...</div>
});

export default function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>

      <Suspense fallback={<div>Loading...</div>}>
        <HeavyChart />
      </Suspense>

      <Suspense fallback={<div>Loading...</div>}>
        <AdminPanel />
      </Suspense>
    </div>
  );
}
```

#### ライブラリレベル分割
```jsx
// hooks/useChart.ts
import { useState, useEffect } from 'react';

export function useChart() {
  const [Chart, setChart] = useState(null);

  useEffect(() => {
    // Chart.js を動的にインポート
    import('chart.js').then((chartModule) => {
      setChart(() => chartModule.Chart);
    });
  }, []);

  return Chart;
}
```

### 2. Tree Shaking最適化

#### Lodash の最適化例
```javascript
// 悪い例
import _ from 'lodash';
const result = _.debounce(callback, 300);

// 良い例
import { debounce } from 'lodash';
const result = debounce(callback, 300);

// さらに良い例
import debounce from 'lodash/debounce';
const result = debounce(callback, 300);
```

#### Webpack Bundle Analyzer 設定
```json
// package.json
{
  "scripts": {
    "analyze": "cross-env ANALYZE=true next build",
    "analyze:server": "cross-env BUNDLE_ANALYZE=server next build",
    "analyze:browser": "cross-env BUNDLE_ANALYZE=browser next build"
  }
}
```

```javascript
// next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
});

module.exports = withBundleAnalyzer({
  // Next.js設定
});
```

## 🚀 レンダリング最適化

### 1. Server-Side Rendering (SSR) vs Static Generation (SSG)

#### SSG での最適化
```jsx
// pages/blog/[slug].tsx
import { GetStaticPaths, GetStaticProps } from 'next';

export default function BlogPost({ post, relatedPosts }) {
  return (
    <article>
      <h1>{post.title}</h1>
      <div dangerouslySetInnerHTML={{ __html: post.content }} />

      {/* 関連記事も事前生成 */}
      <aside>
        <h3>Related Posts</h3>
        {relatedPosts.map(post => (
          <Link key={post.id} href={`/blog/${post.slug}`}>
            {post.title}
          </Link>
        ))}
      </aside>
    </article>
  );
}

export const getStaticPaths: GetStaticPaths = async () => {
  const posts = await getAllPosts();

  return {
    paths: posts.map(post => ({ params: { slug: post.slug } })),
    fallback: 'blocking' // ISR を有効化
  };
};

export const getStaticProps: GetStaticProps = async ({ params }) => {
  const post = await getPostBySlug(params?.slug as string);
  const relatedPosts = await getRelatedPosts(post.tags);

  return {
    props: { post, relatedPosts },
    revalidate: 3600 // 1時間でrevalidate
  };
};
```

#### ISR (Incremental Static Regeneration) 活用
```jsx
// pages/products/[id].tsx
export const getStaticProps: GetStaticProps = async ({ params }) => {
  const product = await getProduct(params?.id as string);

  if (!product) {
    return { notFound: true };
  }

  return {
    props: { product },
    revalidate: 300, // 5分間隔でrevalidate
  };
};
```

### 2. React最適化パターン

#### useMemo と useCallback の適切な使用
```jsx
// components/ExpensiveList.tsx
import { useMemo, useCallback, memo } from 'react';

interface Item {
  id: string;
  name: string;
  price: number;
  category: string;
}

interface ExpensiveListProps {
  items: Item[];
  onItemClick: (id: string) => void;
  filter: string;
}

const ExpensiveList = memo(function ExpensiveList({
  items,
  onItemClick,
  filter
}: ExpensiveListProps) {
  // 高価な計算をメモ化
  const filteredItems = useMemo(() => {
    return items.filter(item =>
      item.name.toLowerCase().includes(filter.toLowerCase())
    );
  }, [items, filter]);

  // コールバック関数をメモ化
  const handleItemClick = useCallback((id: string) => {
    onItemClick(id);
  }, [onItemClick]);

  return (
    <ul>
      {filteredItems.map(item => (
        <ListItem
          key={item.id}
          item={item}
          onClick={handleItemClick}
        />
      ))}
    </ul>
  );
});

// 子コンポーネントもメモ化
const ListItem = memo(function ListItem({
  item,
  onClick
}: {
  item: Item;
  onClick: (id: string) => void;
}) {
  return (
    <li onClick={() => onClick(item.id)}>
      <h3>{item.name}</h3>
      <p>${item.price}</p>
    </li>
  );
});
```

#### Virtual Scrolling 実装
```jsx
// components/VirtualList.tsx
import { FixedSizeList as List } from 'react-window';

interface VirtualListProps {
  items: any[];
  height: number;
  itemHeight: number;
}

const Row = ({ index, style, data }) => (
  <div style={style}>
    <div className="p-4 border-b">
      {data[index].name}
    </div>
  </div>
);

export function VirtualList({ items, height, itemHeight }: VirtualListProps) {
  return (
    <List
      height={height}
      itemCount={items.length}
      itemSize={itemHeight}
      itemData={items}
    >
      {Row}
    </List>
  );
}
```

## 🌐 ネットワーク最適化

### 1. Service Worker とキャッシング

#### PWA 設定
```javascript
// next.config.js
const withPWA = require('next-pwa')({
  dest: 'public',
  register: true,
  skipWaiting: true,
  runtimeCaching: [
    {
      urlPattern: /^https?.*/,
      handler: 'NetworkFirst',
      options: {
        cacheName: 'offlineCache',
        expiration: {
          maxEntries: 200,
          maxAgeSeconds: 24 * 60 * 60 // 24 hours
        }
      }
    }
  ]
});

module.exports = withPWA({
  // Next.js設定
});
```

### 2. CDN とリソース最適化

#### 静的アセット最適化
```javascript
// next.config.js
const nextConfig = {
  assetPrefix: process.env.NODE_ENV === 'production'
    ? 'https://cdn.example.com'
    : '',

  async headers() {
    return [
      {
        source: '/_next/static/(.*)',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable'
          }
        ]
      },
      {
        source: '/images/(.*)',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=86400'
          }
        ]
      }
    ];
  }
};
```

## 📊 パフォーマンス測定とモニタリング

### 1. Core Web Vitals 測定

#### 自動計測実装
```jsx
// pages/_app.tsx
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

function reportWebVitals(metric) {
  // アナリティクスに送信
  if (typeof window !== 'undefined' && window.gtag) {
    window.gtag('event', metric.name, {
      event_category: 'Web Vitals',
      event_label: metric.id,
      value: Math.round(metric.name === 'CLS' ? metric.value * 1000 : metric.value),
      non_interaction: true
    });
  }

  // 開発環境でのログ出力
  if (process.env.NODE_ENV === 'development') {
    console.log(metric);
  }
}

export function reportWebVitals(metric) {
  reportWebVitals(metric);
}

// Web Vitals 初期化
if (typeof window !== 'undefined') {
  getCLS(reportWebVitals);
  getFID(reportWebVitals);
  getFCP(reportWebVitals);
  getLCP(reportWebVitals);
  getTTFB(reportWebVitals);
}
```

### 2. Lighthouse CI 統合

#### GitHub Actions 設定
```yaml
# .github/workflows/lighthouse.yml
name: Lighthouse CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  lighthouse:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '22'
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Build application
      run: npm run build

    - name: Start application
      run: npm start &

    - name: Wait for server
      run: npx wait-on http://localhost:3000

    - name: Run Lighthouse CI
      run: |
        npm install -g @lhci/cli
        lhci collect --url=http://localhost:3000
        lhci assert
```

#### Lighthouse設定
```json
// lighthouserc.json
{
  "ci": {
    "collect": {
      "numberOfRuns": 3,
      "startServerCommand": "npm start",
      "url": ["http://localhost:3000", "http://localhost:3000/example"]
    },
    "assert": {
      "assertions": {
        "categories:performance": ["error", {"minScore": 0.8}],
        "categories:accessibility": ["error", {"minScore": 0.9}],
        "categories:best-practices": ["error", {"minScore": 0.9}],
        "categories:seo": ["error", {"minScore": 0.9}]
      }
    }
  }
}
```

## 🎯 学習段階別最適化ガイド

### 初級者（基本最適化）
1. ✅ Next.js Image コンポーネント使用
2. ✅ 基本的なSSG/SSR理解
3. ⏳ 画像フォーマット最適化
4. ⏳ バンドルサイズ分析

### 中級者（実践最適化）
1. ⏳ 動的インポートとCode Splitting
2. ⏳ React最適化パターン実装
3. ⏳ Core Web Vitals測定
4. ⏳ キャッシング戦略実装

### 上級者（高度最適化）
1. ⏳ Service Worker実装
2. ⏳ Virtual Scrolling導入
3. ⏳ CDN統合と最適化
4. ⏳ パフォーマンス監視自動化

## 📈 最適化効果測定

### 目標指標
- **LCP**: < 2.5秒
- **FID**: < 100ms
- **CLS**: < 0.1
- **バンドルサイズ**: < 250KB (gzipped)
- **Lighthouse Score**: > 90点

### 継続的改善プロセス
1. 週次パフォーマンス測定
2. ボトルネック特定と改善
3. 新機能追加時の影響評価
4. ユーザー体験フィードバック収集

この最適化戦略により、高性能でユーザーフレンドリーなNext.jsアプリケーションの構築方法を学習できます。
