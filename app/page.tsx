"use client";

import Button from "@/components/Button";
import FeatureCard from "@/components/FeatureCard";
import StatsSection from "@/components/StatsSection";

export default function Home() {
  return (
    <div className="bg-linear-to-br min-h-screen from-background via-background to-accent/5">
      {/* Header */}
      <header className="bg-background/98 fixed left-0 right-0 top-0 z-50 border-b border-border/60 shadow-sm backdrop-blur-md">
        <div className="container mx-auto flex items-center justify-between px-6 py-4">
          <h1 className="text-xl font-bold">Next.js テンプレート</h1>
          <div className="flex items-center space-x-3">
            <span className="text-sm text-muted-foreground">v0.1.0</span>
            <div className="h-2 w-2 animate-pulse rounded-full bg-green-500"></div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="pt-20">
        {/* Hero Section */}
        <section className="container mx-auto px-6 py-16 text-center">
          <div className="mx-auto max-w-3xl">
            <div className="mb-6 inline-flex items-center rounded-full bg-primary/10 px-3 py-1 text-sm font-medium text-primary">
              <span className="mr-2 h-2 w-2 animate-pulse rounded-full bg-primary"></span>
              学習最適化済み
            </div>

            <h1 className="bg-linear-to-r mb-6 from-foreground to-foreground/80 bg-clip-text text-4xl font-bold text-transparent md:text-5xl">
              Next.js 学習テンプレート
            </h1>

            <p className="mb-8 text-lg leading-relaxed text-muted-foreground">
              Docker環境固定、自動セットアップ、日本語最適化で
              <br />
              迷わず学習に集中できる実践的なNext.js環境
            </p>

            <div className="flex flex-col justify-center gap-4 sm:flex-row">
              <Button size="lg" onClick={() => window.open("http://localhost:3000", "_blank")}>
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
          <div className="mb-12 text-center">
            <h2 className="mb-4 text-2xl font-bold md:text-3xl">主な特徴</h2>
            <p className="text-muted-foreground">学習効率を最大化する設計</p>
          </div>

          <div className="mb-16 grid gap-8 md:grid-cols-3">
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
          <div className="mx-auto max-w-4xl">
            <div className="mb-8 text-center">
              <h2 className="mb-4 text-2xl font-bold md:text-3xl">クイックスタート</h2>
              <p className="text-muted-foreground">3ステップで学習開始</p>
            </div>

            <div className="grid gap-8 md:grid-cols-2">
              <div className="bg-card/98 rounded-lg border border-border/60 p-6 shadow-sm">
                <h3 className="mb-4 text-lg font-semibold text-primary">💻 ローカル環境</h3>
                <div className="rounded-md border border-border/40 bg-muted/60 p-4 font-mono text-sm">
                  <div className="mb-1 text-muted-foreground"># テンプレートクローン</div>
                  <div>git clone &lt;repository&gt;</div>
                  <div>cd next-tpl</div>
                  <div className="mb-1 mt-3 text-muted-foreground"># 自動セットアップ</div>
                  <div className="font-semibold text-primary">./setup</div>
                </div>
              </div>

              <div className="bg-card/98 rounded-lg border border-border/60 p-6 shadow-sm">
                <h3 className="mb-4 text-lg font-semibold text-green-600">🐳 Docker環境</h3>
                <div className="rounded-md border border-border/40 bg-muted/60 p-4 font-mono text-sm">
                  <div className="mb-1 text-muted-foreground"># Docker開発環境</div>
                  <div className="font-semibold text-green-600">make dev-docker</div>
                  <div className="mb-1 mt-3 text-muted-foreground"># または</div>
                  <div className="font-semibold text-green-600">npm run docker:dev</div>
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
