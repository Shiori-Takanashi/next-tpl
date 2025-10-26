# Next.js学習テンプレート Makefile

.PHONY: help setup dev dev-docker build build-docker clean clean-docker cleanup cleanup-dry test lint

# デフォルトターゲット
help:
	@echo "📚 Next.js学習テンプレート - 利用可能なコマンド"
	@echo ""
	@echo "🚀 セットアップ:"
	@echo "  make setup      - インタラクティブセットアップ"
	@echo "  make install    - 依存関係インストール"
	@echo ""
	@echo "🔧 開発:"
	@echo "  make dev        - ローカル開発サーバー起動"
	@echo "  make dev-docker - Docker開発サーバー起動"
	@echo ""
	@echo "🏗️  ビルド:"
	@echo "  make build      - ローカルビルド"
	@echo "  make build-docker - Dockerイメージビルド"
	@echo ""
	@echo "🧹 クリーンアップ:"
	@echo "  make clean      - ローカル環境クリーンアップ"
	@echo "  make clean-docker - Docker環境クリーンアップ"
	@echo "  make cleanup    - 高度なファイルクリーンアップ"
	@echo "  make cleanup-dry - クリーンアップ対象ファイル表示"
	@echo ""
	@echo "✅ チェック:"
	@echo "  make lint       - ESLintチェック"
	@echo "  make test       - テスト実行（将来用）"

# セットアップ
setup:
	@./setup

install:
	@echo "📦 依存関係をインストールします..."
	npm install
	@echo "✅ インストール完了"

# 開発
dev:
	@echo "🚀 ローカル開発サーバーを起動します..."
	npm run dev

dev-docker:
	@echo "🐳 Docker開発サーバーを起動します..."
	docker-compose up next-tpl-dev

dev-docker-bg:
	@echo "🐳 Docker開発サーバーをバックグラウンドで起動します..."
	docker-compose up -d next-tpl-dev

# ビルド
build:
	@echo "🏗️  ローカルビルドを実行します..."
	npm run build

build-docker:
	@echo "🐳 Dockerイメージをビルドします..."
	docker-compose build next-tpl-dev

build-docker-prod:
	@echo "🐳 本番用Dockerイメージをビルドします..."
	docker-compose build next-tpl

# クリーンアップ
clean:
	@echo "🧹 ローカル環境をクリーンアップします..."
	rm -rf node_modules
	rm -rf .next
	rm -f package-lock.json
	@echo "✅ クリーンアップ完了"

clean-docker:
	@echo "🧹 Docker環境をクリーンアップします..."
	docker-compose down
	docker system prune -f
	@echo "✅ Dockerクリーンアップ完了"

# 高度なクリーンアップ
cleanup:
	@echo "🧹 高度なファイルクリーンアップを実行します..."
	./tools/cleanup.zsh --force

cleanup-dry:
	@echo "🔍 クリーンアップ対象ファイルを表示します..."
	./tools/cleanup.zsh --dry-run

# チェック
lint:
	@echo "🔍 ESLintチェックを実行します..."
	npm run lint

test:
	@echo "🧪 テストを実行します..."
	@echo "（まだテストは設定されていません）"

# 学習用ヘルパー
learn-start:
	@echo "🎓 新しい学習セッションを開始します..."
	@echo "現在のブランチ: $$(git branch --show-current)"
	@read -p "新しい学習ブランチ名を入力してください: " branch; \
	git checkout -b learn/$$branch
	@echo "✅ 学習ブランチ learn/$$branch を作成しました"

learn-reset:
	@echo "🔄 学習環境をリセットします..."
	git checkout main
	git pull origin main 2>/dev/null || echo "リモートからのpullに失敗（ローカルのみ）"
	@echo "✅ mainブランチに戻りました"
