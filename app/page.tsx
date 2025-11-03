'use client';

import Button from '@/components/Button';
import FeatureCard from '@/components/FeatureCard';
import StatsSection from '@/components/StatsSection';

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-background via-background to-accent/5">
      {/* Header */}
      <header className="bg-background/98 backdrop-blur-md border-b border-border/60 fixed top-0 left-0 right-0 z-50 shadow-sm">
        <div className="container mx-auto px-6 py-4 flex items-center justify-between">
          <h1 className="text-xl font-bold">Next.js テンプレート</h1>
          <div className="flex items-center space-x-3">
            <span className="text-sm text-muted-foreground">v0.1.0</span>
            <div className="h-2 w-2 bg-green-500 rounded-full animate-pulse"></div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="pt-20">
        {/* Hero Section */}
        <section className="container mx-auto px-6 py-16 text-center">
          <div className="max-w-3xl mx-auto">
            <div className="inline-flex items-center px-3 py-1 bg-primary/10 text-primary rounded-full text-sm font-medium mb-6">
              <span className="w-2 h-2 bg-primary rounded-full mr-2 animate-pulse"></span>
              学習最適化済み
            </div>

            <h1 className="text-4xl md:text-5xl font-bold mb-6 bg-gradient-to-r from-foreground to-foreground/80 bg-clip-text text-transparent">
              Next.js 学習テンプレート
            </h1>

            <p className="text-lg text-muted-foreground mb-8 leading-relaxed">
              Docker環境固定、自動セットアップ、日本語最適化で<br />
              迷わず学習に集中できる実践的なNext.js環境
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Button size="lg" onClick={() => window.open('http://localhost:3000', '_blank')}>
                🚀 学習を開始
              </Button>
              <Button variant="outline" size="lg">
                📚 ドキュメント
              </Button>
            </div>
          </div>
        </section>

        {/* Features */}
        <section className="container mx-auto px-6 py-12">
          <div className="text-center mb-12">
            <h2 className="text-2xl md:text-3xl font-bold mb-4">主な特徴</h2>
            <p className="text-muted-foreground">学習効率を最大化する設計</p>
          </div>

          <div className="grid md:grid-cols-3 gap-8 mb-16">
            <FeatureCard
              icon="🔒"
              title="完全環境固定"
              description="Node.js 22.11.0、Next.js 16.0.0を完全固定。Dockerによる環境統一でトラブル回避。"
            />
            <FeatureCard
              icon="⚡"
              title="自動セットアップ"
              description="シェル検出、Node.js管理、Docker選択を自動化。1コマンドで学習環境完成。"
            />
            <FeatureCard
              icon="🎌"
              title="日本語最適化"
              description="フォント、UI、ドキュメントすべて日本語学習者向けに最適化済み。"
            />
          </div>

          {/* Stats */}
          <StatsSection />
        </section>

        {/* Quick Start */}
        <section className="container mx-auto px-6 py-12">
          <div className="max-w-4xl mx-auto">
            <div className="text-center mb-8">
              <h2 className="text-2xl md:text-3xl font-bold mb-4">クイックスタート</h2>
              <p className="text-muted-foreground">3ステップで学習開始</p>
            </div>

            <div className="grid md:grid-cols-2 gap-8">
              <div className="bg-card/98 border border-border/60 rounded-lg p-6 shadow-sm">
                <h3 className="text-lg font-semibold text-primary mb-4">
                  💻 ローカル環境
                </h3>
                <div className="bg-muted/60 rounded-md p-4 font-mono text-sm border border-border/40">
                  <div className="text-muted-foreground mb-1"># テンプレートクローン</div>
                  <div>git clone &lt;repository&gt;</div>
                  <div>cd next-tpl</div>
                  <div className="text-muted-foreground mt-3 mb-1"># 自動セットアップ</div>
                  <div className="text-primary font-semibold">./setup</div>
                </div>
              </div>

              <div className="bg-card/98 border border-border/60 rounded-lg p-6 shadow-sm">
                <h3 className="text-lg font-semibold text-green-600 mb-4">
                  🐳 Docker環境
                </h3>
                <div className="bg-muted/60 rounded-md p-4 font-mono text-sm border border-border/40">
                  <div className="text-muted-foreground mb-1"># Docker開発環境</div>
                  <div className="text-green-600 font-semibold">make dev-docker</div>
                  <div className="text-muted-foreground mt-3 mb-1"># または</div>
                  <div className="text-green-600 font-semibold">npm run docker:dev</div>
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t bg-muted/30 py-8">
        <div className="container mx-auto px-6 text-center">
          <p className="text-sm text-muted-foreground">
            Next.js 学習テンプレート - 安定した学習環境で効率的な成長を
          </p>
        </div>
      </footer>
    </div>
  );
}
