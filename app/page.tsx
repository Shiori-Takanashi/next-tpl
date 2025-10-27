export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50 dark:from-gray-900 dark:via-blue-900 dark:to-indigo-900">
      {/* Navigation */}
      <nav className="glass fixed top-0 left-0 right-0 z-50 border-b">
        <div className="container mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <h1 className="text-xl font-bold gradient-text">
              Next.js学習テンプレート
            </h1>
            <div className="flex items-center space-x-4">
              <span className="text-sm text-muted-foreground">v0.1.0</span>
              <div className="h-2 w-2 bg-green-500 rounded-full animate-pulse-subtle"></div>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <main className="pt-20">
        <section className="container mx-auto px-6 py-16 text-center">
          <div className="animate-fade-in">
            <div className="inline-flex items-center px-4 py-2 bg-primary/10 text-primary rounded-full text-sm font-medium mb-8">
              <span className="w-2 h-2 bg-primary rounded-full mr-2"></span>
              学習に最適化された環境
            </div>

            <h1 className="text-4xl md:text-6xl font-bold gradient-text mb-6 font-ja">
              次世代Web開発を<br />
              今すぐ始めよう
            </h1>

            <p className="text-xl text-muted-foreground mb-12 max-w-2xl mx-auto font-ja leading-relaxed">
              Docker環境固定化とセットアップ自動化により、<br />
              迷わず学習に集中できる実践的なNext.js学習環境
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center mb-16">
              <button className="group px-8 py-4 bg-primary text-primary-foreground rounded-lg font-semibold transition-all duration-200 hover:bg-primary/90 hover:shadow-lg hover:scale-105 focus-ring">
                <span className="flex items-center justify-center">
                  🚀 学習を開始する
                  <svg className="ml-2 w-4 h-4 transition-transform group-hover:translate-x-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                  </svg>
                </span>
              </button>

              <button className="px-8 py-4 border border-border text-foreground rounded-lg font-semibold transition-all duration-200 hover:bg-accent hover:shadow-md focus-ring">
                📚 ドキュメントを見る
              </button>
            </div>
          </div>

          {/* Feature Cards */}
          <div className="grid md:grid-cols-3 gap-8 mb-20">
            <div className="glass rounded-xl p-8 transition-all duration-300 hover:shadow-lg hover:scale-105 animate-fade-in">
              <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl flex items-center justify-center text-white text-2xl mb-6 mx-auto">
                🔒
              </div>
              <h3 className="text-xl font-bold mb-4 font-ja">完全環境固定</h3>
              <p className="text-muted-foreground font-ja leading-relaxed">
                Node.js 22.11.0、Next.js 16.0.0、React 19.2.0を完全固定。
                Dockerによる環境隔離で一貫した開発体験。
              </p>
            </div>

            <div className="glass rounded-xl p-8 transition-all duration-300 hover:shadow-lg hover:scale-105 animate-fade-in" style={{animationDelay: '0.1s'}}>
              <div className="w-16 h-16 bg-gradient-to-br from-green-500 to-green-600 rounded-xl flex items-center justify-center text-white text-2xl mb-6 mx-auto">
                ⚡
              </div>
              <h3 className="text-xl font-bold mb-4 font-ja">自動セットアップ</h3>
              <p className="text-muted-foreground font-ja leading-relaxed">
                シェル自動検出、Node.jsバージョン管理、Docker環境選択。
                1コマンドで学習環境が完成。
              </p>
            </div>

            <div className="glass rounded-xl p-8 transition-all duration-300 hover:shadow-lg hover:scale-105 animate-fade-in" style={{animationDelay: '0.2s'}}>
              <div className="w-16 h-16 bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl flex items-center justify-center text-white text-2xl mb-6 mx-auto">
                📖
              </div>
              <h3 className="text-xl font-bold mb-4 font-ja">実践的学習</h3>
              <p className="text-muted-foreground font-ja leading-relaxed">
                React Hooks、TypeScript、TailwindCSSを使った
                実際に動くサンプルコードで効率学習。
              </p>
            </div>
          </div>

          {/* Quick Start Section */}
          <div className="glass rounded-2xl p-8 max-w-4xl mx-auto animate-fade-in" style={{animationDelay: '0.3s'}}>
            <h2 className="text-3xl font-bold mb-8 font-ja">🚀 クイックスタート</h2>

            <div className="grid md:grid-cols-2 gap-8">
              <div className="text-left">
                <h3 className="text-lg font-semibold text-primary mb-4 font-ja">
                  最簡単セットアップ
                </h3>
                <div className="bg-card rounded-lg p-4 border font-mono text-sm">
                  <div className="text-muted-foreground mb-1"># テンプレートをクローン</div>
                  <div className="text-foreground">git clone &lt;repository-url&gt; my-project</div>
                  <div className="text-foreground">cd my-project</div>
                  <div className="text-muted-foreground mt-3 mb-1"># 自動セットアップ実行</div>
                  <div className="text-primary font-semibold">./setup</div>
                </div>
              </div>

              <div className="text-left">
                <h3 className="text-lg font-semibold text-green-600 mb-4 font-ja">
                  Docker版（完全隔離）
                </h3>
                <div className="bg-card rounded-lg p-4 border font-mono text-sm">
                  <div className="text-muted-foreground mb-1"># Docker開発環境起動</div>
                  <div className="text-green-600 font-semibold">make dev-docker</div>
                  <div className="text-muted-foreground mt-3 mb-1"># または</div>
                  <div className="text-green-600 font-semibold">npm run docker:dev</div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Stats Section */}
        <section className="border-t bg-muted/50 py-16">
          <div className="container mx-auto px-6">
            <div className="grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
              <div className="animate-slide-in">
                <div className="text-3xl font-bold gradient-text">22.11.0</div>
                <div className="text-sm text-muted-foreground font-ja">Node.js版</div>
              </div>
              <div className="animate-slide-in" style={{animationDelay: '0.1s'}}>
                <div className="text-3xl font-bold gradient-text">16.0.0</div>
                <div className="text-sm text-muted-foreground font-ja">Next.js版</div>
              </div>
              <div className="animate-slide-in" style={{animationDelay: '0.2s'}}>
                <div className="text-3xl font-bold gradient-text">19.2.0</div>
                <div className="text-sm text-muted-foreground font-ja">React版</div>
              </div>
              <div className="animate-slide-in" style={{animationDelay: '0.3s'}}>
                <div className="text-3xl font-bold gradient-text">100%</div>
                <div className="text-sm text-muted-foreground font-ja">環境固定</div>
              </div>
            </div>
          </div>
        </section>
      </main>
    </div>
  );
}
