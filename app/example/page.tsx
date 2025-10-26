/**
 * サンプルページ - Next.js学習用
 *
 * このページは以下の学習内容を含んでいます：
 * - App Routerの基本的な使い方
 * - TypeScriptの型定義
 * - TailwindCSSのスタイリング
 * - React Hooksの使用例
 * - 状態管理の基本
 */
'use client';

import { useState, useEffect } from 'react';

// TypeScript: Props型の定義例
interface CounterProps {
    initialCount?: number;
}

// TypeScript: 状態型の定義例
interface AppState {
    count: number;
    message: string;
    isLoading: boolean;
}

// サブコンポーネント例
function Counter({ initialCount = 0 }: CounterProps) {
    const [count, setCount] = useState(initialCount);

    return (
        <div className="bg-blue-50 p-6 rounded-lg">
            <h3 className="text-lg font-semibold mb-4 text-blue-800">
                カウンターコンポーネント
            </h3>
            <div className="flex items-center gap-4">
                <button
                    onClick={() => setCount(c => c - 1)}
                    className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition-colors"
                >
                    -1
                </button>
                <span className="text-2xl font-bold text-blue-700 min-w-[3rem] text-center">
                    {count}
                </span>
                <button
                    onClick={() => setCount(c => c + 1)}
                    className="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 transition-colors"
                >
                    +1
                </button>
            </div>
            <button
                onClick={() => setCount(initialCount)}
                className="mt-3 px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600 transition-colors text-sm"
            >
                リセット
            </button>
        </div>
    );
}

// メインページコンポーネント
export default function ExamplePage() {
    // useState Hook - 状態管理の基本
    const [state, setState] = useState<AppState>({
        count: 0,
        message: '',
        isLoading: false
    });

    // useEffect Hook - 副作用の管理
    useEffect(() => {
        // マウント時の処理例
        console.log('ExamplePageがマウントされました');

        // 初期メッセージの設定
        setState(prev => ({
            ...prev,
            message: 'Next.js学習テンプレートへようこそ！'
        }));

        // クリーンアップ関数
        return () => {
            console.log('ExamplePageがアンマウントされます');
        };
    }, []);

    // イベントハンドラー例
    const handleMessageChange = (newMessage: string) => {
        setState(prev => ({
            ...prev,
            message: newMessage
        }));
    };

    // 非同期処理の例
    const handleAsyncAction = async () => {
        setState(prev => ({ ...prev, isLoading: true }));

        try {
            // 擬似的な非同期処理
            await new Promise(resolve => setTimeout(resolve, 1000));
            handleMessageChange('非同期処理が完了しました！');
        } catch (error) {
            console.error('エラーが発生しました:', error);
            handleMessageChange('エラーが発生しました');
        } finally {
            setState(prev => ({ ...prev, isLoading: false }));
        }
    };

    return (
        <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-6">
            <div className="max-w-4xl mx-auto">
                {/* ページヘッダー */}
                <header className="text-center mb-8">
                    <h1 className="text-4xl font-bold text-gray-800 mb-4">
                        📚 Next.js学習サンプル
                    </h1>
                    <p className="text-gray-600 text-lg">
                        このページでNext.jsの基本的な機能を学習できます
                    </p>
                </header>

                {/* メインコンテンツ */}
                <main className="space-y-8">
                    {/* メッセージ表示セクション */}
                    <section className="bg-white p-6 rounded-lg shadow-md">
                        <h2 className="text-2xl font-semibold mb-4 text-gray-800">
                            🎯 状態管理とイベント処理
                        </h2>

                        <div className="space-y-4">
                            <div className="p-4 bg-gray-50 rounded border-l-4 border-blue-500">
                                <p className="text-gray-700 font-medium">現在のメッセージ:</p>
                                <p className="text-lg text-blue-700">{state.message}</p>
                            </div>

                            <div className="flex gap-3 flex-wrap">
                                <button
                                    onClick={() => handleMessageChange('こんにちは、Next.js！')}
                                    className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
                                >
                                    挨拶メッセージ
                                </button>

                                <button
                                    onClick={() => handleMessageChange('TypeScriptで型安全な開発！')}
                                    className="px-4 py-2 bg-purple-500 text-white rounded hover:bg-purple-600 transition-colors"
                                >
                                    TypeScriptメッセージ
                                </button>

                                <button
                                    onClick={handleAsyncAction}
                                    disabled={state.isLoading}
                                    className="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                                >
                                    {state.isLoading ? '処理中...' : '非同期処理実行'}
                                </button>

                                <button
                                    onClick={() => handleMessageChange('')}
                                    className="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600 transition-colors"
                                >
                                    クリア
                                </button>
                            </div>
                        </div>
                    </section>

                    {/* コンポーネント例 */}
                    <section className="bg-white p-6 rounded-lg shadow-md">
                        <h2 className="text-2xl font-semibold mb-4 text-gray-800">
                            🧩 コンポーネントの組み合わせ
                        </h2>

                        <div className="grid md:grid-cols-2 gap-6">
                            <Counter initialCount={0} />
                            <Counter initialCount={10} />
                        </div>
                    </section>

                    {/* 学習項目リスト */}
                    <section className="bg-white p-6 rounded-lg shadow-md">
                        <h2 className="text-2xl font-semibold mb-4 text-gray-800">
                            📖 このページで学べること
                        </h2>

                        <div className="grid md:grid-cols-2 gap-4">
                            <div>
                                <h3 className="font-semibold text-lg mb-2 text-blue-700">React / Next.js</h3>
                                <ul className="space-y-1 text-gray-600">
                                    <li>• useState Hookの使用</li>
                                    <li>• useEffect Hookの使用</li>
                                    <li>• イベントハンドリング</li>
                                    <li>• コンポーネント間の値渡し</li>
                                    <li>• 非同期処理の実装</li>
                                </ul>
                            </div>

                            <div>
                                <h3 className="font-semibold text-lg mb-2 text-purple-700">TypeScript</h3>
                                <ul className="space-y-1 text-gray-600">
                                    <li>• インターフェースの定義</li>
                                    <li>• 型安全な状態管理</li>
                                    <li>• Propsの型定義</li>
                                    <li>• Genericsの使用</li>
                                    <li>• Optional Properties</li>
                                </ul>
                            </div>
                        </div>
                    </section>

                    {/* ナビゲーション */}
                    <section className="bg-white p-6 rounded-lg shadow-md">
                        <h2 className="text-2xl font-semibold mb-4 text-gray-800">
                            🚀 次のステップ
                        </h2>

                        <div className="flex gap-4 flex-wrap">
                            <a
                                href="/"
                                className="px-6 py-3 bg-indigo-500 text-white rounded-lg hover:bg-indigo-600 transition-colors"
                            >
                                ← ホームページに戻る
                            </a>

                            <a
                                href="https://nextjs.org/learn"
                                target="_blank"
                                rel="noopener noreferrer"
                                className="px-6 py-3 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors"
                            >
                                Next.js公式チュートリアル
                            </a>
                        </div>
                    </section>
                </main>
            </div>
        </div>
    );
}
