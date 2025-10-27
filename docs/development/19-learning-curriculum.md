# 学習カリキュラム設計と実装戦略

## 概要
Next.jsテンプレートを活用した段階的学習カリキュラムの設計記録

## 学習者レベル別カリキュラム

### 🌱 初級者（0-3ヶ月目標）

#### Week 1-2: 環境構築とNext.js基礎
```bash
# 学習目標
- Next.jsプロジェクトの起動
- ファイル構造の理解
- 基本的なページ作成
```

**実践課題**:
```typescript
// app/hello/page.tsx - 新しいページ作成
export default function HelloPage() {
  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold">Hello, Next.js!</h1>
      <p className="mt-4">私の最初のNext.jsページです。</p>
    </div>
  );
}
```

#### Week 3-4: React基礎とコンポーネント
```typescript
// components/Button.tsx - 基本コンポーネント
interface ButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  variant?: 'primary' | 'secondary';
}

export default function Button({
  children,
  onClick,
  variant = 'primary'
}: ButtonProps) {
  return (
    <button
      onClick={onClick}
      className={`px-4 py-2 rounded ${
        variant === 'primary'
          ? 'bg-blue-500 text-white'
          : 'bg-gray-200 text-gray-800'
      }`}
    >
      {children}
    </button>
  );
}
```

#### Week 5-6: State管理とイベント処理
```typescript
// app/counter/page.tsx - useState実践
'use client';
import { useState } from 'react';

export default function CounterPage() {
  const [count, setCount] = useState(0);

  return (
    <div className="p-8 text-center">
      <h1 className="text-3xl font-bold mb-4">カウンター</h1>
      <p className="text-xl mb-4">現在の値: {count}</p>
      <div className="space-x-4">
        <button
          onClick={() => setCount(count + 1)}
          className="px-4 py-2 bg-green-500 text-white rounded"
        >
          +1
        </button>
        <button
          onClick={() => setCount(count - 1)}
          className="px-4 py-2 bg-red-500 text-white rounded"
        >
          -1
        </button>
        <button
          onClick={() => setCount(0)}
          className="px-4 py-2 bg-gray-500 text-white rounded"
        >
          リセット
        </button>
      </div>
    </div>
  );
}
```

#### Week 7-8: TypeScript基礎
```typescript
// types/user.ts - 型定義の練習
export interface User {
  id: number;
  name: string;
  email: string;
  age?: number;
}

export type UserStatus = 'active' | 'inactive' | 'pending';

export interface UserWithStatus extends User {
  status: UserStatus;
}
```

### 🌿 中級者（3-6ヶ月目標）

#### Month 3-4: ルーティングとレイアウト
```typescript
// app/blog/layout.tsx - ネストレイアウト
export default function BlogLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <nav className="mb-8">
        <h1 className="text-2xl font-bold mb-4">ブログ</h1>
        <ul className="flex space-x-4">
          <li><a href="/blog" className="text-blue-500">ホーム</a></li>
          <li><a href="/blog/about" className="text-blue-500">について</a></li>
        </ul>
      </nav>
      <main>{children}</main>
    </div>
  );
}
```

#### Month 4-5: API統合とデータフェッチ
```typescript
// app/api/users/route.ts - API Route実装
import { NextResponse } from 'next/server';

const users = [
  { id: 1, name: '田中太郎', email: 'tanaka@example.com' },
  { id: 2, name: '佐藤花子', email: 'sato@example.com' },
];

export async function GET() {
  return NextResponse.json(users);
}

export async function POST(request: Request) {
  const body = await request.json();
  const newUser = { id: Date.now(), ...body };
  users.push(newUser);
  return NextResponse.json(newUser, { status: 201 });
}
```

```typescript
// app/users/page.tsx - データフェッチ
async function getUsers() {
  const res = await fetch('http://localhost:3000/api/users');
  if (!res.ok) throw new Error('Failed to fetch users');
  return res.json();
}

export default async function UsersPage() {
  const users = await getUsers();

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-6">ユーザー一覧</h1>
      <div className="grid gap-4">
        {users.map((user: any) => (
          <div key={user.id} className="p-4 border rounded">
            <h3 className="font-semibold">{user.name}</h3>
            <p className="text-gray-600">{user.email}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
```

#### Month 5-6: フォーム処理とバリデーション
```typescript
// app/contact/page.tsx - フォーム実装
'use client';
import { useState } from 'react';

interface FormData {
  name: string;
  email: string;
  message: string;
}

export default function ContactPage() {
  const [formData, setFormData] = useState<FormData>({
    name: '',
    email: '',
    message: ''
  });
  const [errors, setErrors] = useState<Partial<FormData>>({});

  const validate = (): boolean => {
    const newErrors: Partial<FormData> = {};

    if (!formData.name.trim()) {
      newErrors.name = '名前は必須です';
    }

    if (!formData.email.trim()) {
      newErrors.email = 'メールアドレスは必須です';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = '有効なメールアドレスを入力してください';
    }

    if (!formData.message.trim()) {
      newErrors.message = 'メッセージは必須です';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validate()) {
      console.log('送信データ:', formData);
      alert('メッセージを送信しました！');
    }
  };

  return (
    <div className="max-w-md mx-auto p-8">
      <h1 className="text-2xl font-bold mb-6">お問い合わせ</h1>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm font-medium mb-1">名前</label>
          <input
            type="text"
            value={formData.name}
            onChange={(e) => setFormData({...formData, name: e.target.value})}
            className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          {errors.name && <p className="text-red-500 text-sm mt-1">{errors.name}</p>}
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">メールアドレス</label>
          <input
            type="email"
            value={formData.email}
            onChange={(e) => setFormData({...formData, email: e.target.value})}
            className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          {errors.email && <p className="text-red-500 text-sm mt-1">{errors.email}</p>}
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">メッセージ</label>
          <textarea
            value={formData.message}
            onChange={(e) => setFormData({...formData, message: e.target.value})}
            rows={4}
            className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          {errors.message && <p className="text-red-500 text-sm mt-1">{errors.message}</p>}
        </div>

        <button
          type="submit"
          className="w-full bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-600 transition-colors"
        >
          送信
        </button>
      </form>
    </div>
  );
}
```

### 🌳 上級者（6-12ヶ月目標）

#### Month 6-8: 認証とセキュリティ
```typescript
// middleware.ts - 認証ミドルウェア
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('auth-token');

  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: '/dashboard/:path*'
};
```

#### Month 8-10: パフォーマンス最適化
```typescript
// app/products/page.tsx - Suspenseとストリーミング
import { Suspense } from 'react';

async function ProductList() {
  // 重い処理をシミュレート
  await new Promise(resolve => setTimeout(resolve, 2000));

  return (
    <div className="grid grid-cols-3 gap-4">
      {/* 商品リスト */}
    </div>
  );
}

function ProductSkeleton() {
  return (
    <div className="grid grid-cols-3 gap-4">
      {Array.from({ length: 6 }).map((_, i) => (
        <div key={i} className="h-48 bg-gray-200 animate-pulse rounded" />
      ))}
    </div>
  );
}

export default function ProductsPage() {
  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-6">商品一覧</h1>
      <Suspense fallback={<ProductSkeleton />}>
        <ProductList />
      </Suspense>
    </div>
  );
}
```

#### Month 10-12: テストと品質保証
```typescript
// __tests__/components/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import Button from '@/components/Button';

describe('Button Component', () => {
  test('renders button with children', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  test('calls onClick when clicked', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click me</Button>);

    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  test('applies correct variant styles', () => {
    render(<Button variant="secondary">Secondary</Button>);
    const button = screen.getByText('Secondary');
    expect(button).toHaveClass('bg-gray-200');
  });
});
```

## 実践プロジェクト課題

### 初級: 個人ブログサイト
- マークダウンブログ
- 記事一覧・詳細表示
- カテゴリ分類
- 検索機能

### 中級: ECサイト（フロントエンド）
- 商品一覧・詳細
- ショッピングカート
- ユーザー認証
- 決済フロー

### 上級: 企業向けダッシュボード
- リアルタイムデータ
- 複雑な状態管理
- パフォーマンス最適化
- セキュリティ実装

## 学習評価基準

### 技術理解度チェックリスト

#### React/Next.js基礎
- [ ] コンポーネントの作成と使用
- [ ] propsとstateの理解
- [ ] イベントハンドリング
- [ ] App Routerの理解

#### TypeScript
- [ ] 基本型の理解
- [ ] インターフェース定義
- [ ] 型安全性の活用
- [ ] ジェネリクスの使用

#### スタイリング
- [ ] TailwindCSSの活用
- [ ] レスポンシブデザイン
- [ ] コンポーネントスタイリング
- [ ] アクセシビリティ対応

## 学習リソース

### 公式ドキュメント
- [Next.js Documentation](https://nextjs.org/docs)
- [React Documentation](https://react.dev/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [TailwindCSS Documentation](https://tailwindcss.com/docs)

### 推奨書籍
- 「Reactハンズオンラーニング」
- 「TypeScript入門」
- 「モダンJavaScript入門」

### オンライン学習
- TypeScript公式チュートリアル
- React公式チュートリアル
- Next.js Learn コース

## メンターシップ体制

### コードレビュー観点
1. **コード品質**: 可読性、保守性
2. **TypeScript活用**: 型安全性の確保
3. **パフォーマンス**: 最適化の実装
4. **ベストプラクティス**: 業界標準の遵守

### 定期チェックポイント
- 月次: 学習進捗確認
- 隔週: コードレビュー
- 週次: 質問・相談セッション

---

**作成**: 2025/10/27
**対象**: Next.js学習者全レベル
**更新**: カリキュラム改善時随時
