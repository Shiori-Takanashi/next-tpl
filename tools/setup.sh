#!/bin/bash

# Next.js学習テンプレート セットアップスクリプト

set -e

echo "🚀 Next.js学習テンプレートのセットアップを開始します..."

# Node.jsバージョンチェック
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "📋 現在のNode.jsバージョン: $NODE_VERSION"

    if [[ "$NODE_VERSION" != "v22.11.0" ]]; then
        echo "⚠️  推奨Node.jsバージョン: v22.11.0"
        echo "   現在のバージョン: $NODE_VERSION"

        if command -v nvm &> /dev/null; then
            echo "🔄 nvmを使用してNode.jsバージョンを切り替えます..."
            nvm use
        else
            echo "💡 nvmをインストールして .nvmrc を使用することを推奨します"
        fi
    else
        echo "✅ Node.jsバージョンが適切です"
    fi
else
    echo "❌ Node.jsがインストールされていません"
    exit 1
fi

# Dockerチェック
if command -v docker &> /dev/null; then
    echo "✅ Dockerが利用可能です"
    DOCKER_AVAILABLE=true
else
    echo "⚠️  Dockerが見つかりません（オプション）"
    DOCKER_AVAILABLE=false
fi

# セットアップオプション選択
echo ""
echo "セットアップ方法を選択してください:"
echo "1) ローカル環境（npm install）"
echo "2) Docker開発環境"
echo "3) 両方セットアップ"

read -p "選択 (1-3): " choice

case $choice in
    1)
        echo "📦 ローカル環境をセットアップします..."
        npm install
        echo "✅ セットアップ完了！"
        echo "🚀 開発サーバーを起動: npm run dev"
        ;;
    2)
        if [ "$DOCKER_AVAILABLE" = true ]; then
            echo "🐳 Docker開発環境をセットアップします..."
            docker-compose build next-tpl-dev
            echo "✅ セットアップ完了！"
            echo "🚀 開発サーバーを起動: npm run docker:dev"
        else
            echo "❌ Dockerが利用できません"
            exit 1
        fi
        ;;
    3)
        echo "📦 ローカル環境をセットアップします..."
        npm install
        if [ "$DOCKER_AVAILABLE" = true ]; then
            echo "🐳 Docker環境もセットアップします..."
            docker-compose build next-tpl-dev
            echo "✅ 両方のセットアップ完了！"
            echo "🚀 ローカル: npm run dev"
            echo "🚀 Docker: npm run docker:dev"
        else
            echo "✅ ローカル環境のみセットアップ完了！"
            echo "🚀 開発サーバーを起動: npm run dev"
        fi
        ;;
    *)
        echo "❌ 無効な選択です"
        exit 1
        ;;
esac

echo ""
echo "📚 詳細な使用方法: docs/tpl/point01.md"
echo "🎯 Happy Learning with Next.js!"
