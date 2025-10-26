import Image from "next/image";
import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 dark:from-gray-900 dark:to-black">
      <main className="container mx-auto px-6 py-16">
        {/* ヘッダーセクション */}
        <div className="text-center mb-16">
          <div className="flex justify-center mb-8">
            <Image
              className="dark:invert"
              src="/next.svg"
              alt="Next.js logo"
              width={120}
              height={24}
              priority
            />
          </div>

          <h1 className="text-4xl md:text-6xl font-bold text-gray-800 dark:text-white mb-6">
            Next.js 学習テンプレート
          </h1>

          <p className="text-xl text-gray-600 dark:text-gray-300 mb-8 max-w-2xl mx-auto">
            Docker環境固定化とセットアップ自動化で、すぐに学習を開始できる<br />
            実践的なNext.js学習環境です
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/example"
              className="px-8 py-4 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-lg transition-colors text-lg"
            >
              🚀 学習サンプルを見る
            </Link>

            <a
              href="https://nextjs.org/docs"
              target="_blank"
              rel="noopener noreferrer"
              className="px-8 py-4 border-2 border-blue-600 text-blue-600 hover:bg-blue-600 hover:text-white font-semibold rounded-lg transition-colors text-lg"
            >
              📚 Next.js公式ドキュメント
            </a>
          </div>
        </div>

        {/* 特徴セクション */}
        <div className="grid md:grid-cols-3 gap-8 mb-16">
          <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-md">
            <div className="text-3xl mb-4">🔒</div>
            <h3 className="text-xl font-semibold mb-3 text-gray-800 dark:text-white">
              完全環境固定
            </h3>
            <p className="text-gray-600 dark:text-gray-300">
              Node.js 22.11.0、Next.js 16.0.0、React 19.2.0を完全固定。
              Dockerによる環境隔離で一貫した開発体験を提供。
            </p>
          </div>

          <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-md">
            <div className="text-3xl mb-4">⚡</div>
            <h3 className="text-xl font-semibold mb-3 text-gray-800 dark:text-white">
              自動セットアップ
            </h3>
            <p className="text-gray-600 dark:text-gray-300">
              シェル自動検出、Node.jsバージョン管理、Docker環境選択。
              1コマンドで学習環境が完成。
            </p>
          </div>

          <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-md">
            <div className="text-3xl mb-4">📖</div>
            <h3 className="text-xl font-semibold mb-3 text-gray-800 dark:text-white">
              実践的サンプル
            </h3>
            <p className="text-gray-600 dark:text-gray-300">
              React Hooks、TypeScript、TailwindCSSを使った
              実際に動くサンプルコードで学習。
            </p>
          </div>
        </div>

        {/* クイックスタート */}
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-8 mb-16">
          <h2 className="text-2xl font-bold mb-6 text-gray-800 dark:text-white">
            🚀 クイックスタート
          </h2>

          <div className="grid md:grid-cols-2 gap-8">
            <div>
              <h3 className="text-lg font-semibold mb-3 text-blue-600">
                最簡単セットアップ
              </h3>
              <div className="bg-gray-100 dark:bg-gray-700 p-4 rounded-lg font-mono text-sm">
                <div className="text-gray-600 dark:text-gray-300"># テンプレートをクローン</div>
                <div>git clone &lt;repository-url&gt; my-project</div>
                <div>cd my-project</div>
                <div className="mt-2 text-gray-600 dark:text-gray-300"># 自動セットアップ実行</div>
                <div>./setup</div>
              </div>
            </div>

            <div>
              <h3 className="text-lg font-semibold mb-3 text-green-600">
                Docker版（完全隔離）
              </h3>
              <div className="bg-gray-100 dark:bg-gray-700 p-4 rounded-lg font-mono text-sm">
                <div className="text-gray-600 dark:text-gray-300"># Docker開発環境起動</div>
                <div>make dev-docker</div>
                <div className="mt-2 text-gray-600 dark:text-gray-300"># または</div>
                <div>npm run docker:dev</div>
              </div>
            </div>
          </div>
        </div>

        {/* 学習リソース */}
        <div className="text-center">
          <h2 className="text-2xl font-bold mb-8 text-gray-800 dark:text-white">
            📚 学習リソース
          </h2>

          <div className="grid md:grid-cols-4 gap-4">
            <Link
              href="/example"
              className="bg-blue-500 hover:bg-blue-600 text-white p-4 rounded-lg transition-colors"
            >
              <div className="text-2xl mb-2">🎯</div>
              <div className="font-semibold">実践サンプル</div>
            </Link>

            <a
              href="https://nextjs.org/learn"
              target="_blank"
              rel="noopener noreferrer"
              className="bg-green-500 hover:bg-green-600 text-white p-4 rounded-lg transition-colors"
            >
              <div className="text-2xl mb-2">🎓</div>
              <div className="font-semibold">公式チュートリアル</div>
            </a>

            <a
              href="https://react.dev/learn"
              target="_blank"
              rel="noopener noreferrer"
              className="bg-purple-500 hover:bg-purple-600 text-white p-4 rounded-lg transition-colors"
            >
              <div className="text-2xl mb-2">⚛️</div>
              <div className="font-semibold">React学習</div>
            </a>

            <a
              href="https://www.typescriptlang.org/docs/"
              target="_blank"
              rel="noopener noreferrer"
              className="bg-indigo-500 hover:bg-indigo-600 text-white p-4 rounded-lg transition-colors"
            >
              <div className="text-2xl mb-2">📘</div>
              <div className="font-semibold">TypeScript</div>
            </a>
          </div>
        </div>
      </main>
    </div>
  );
}
