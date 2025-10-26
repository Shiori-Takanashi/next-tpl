# Tools Directory

このディレクトリには、Next.js学習テンプレートのセットアップと管理に使用するスクリプトが含まれています。

## 📁 ファイル構成

```
tools/
├── README.md      # このファイル
├── setup.sh       # Bash版セットアップスクリプト
├── setup.zsh      # Zsh版セットアップスクリプト
└── cleanup.zsh    # 不要ファイル削除スクリプト
```

## 🚀 使用方法

### 自動シェル選択（推奨）
```bash
# ルートディレクトリから実行
./setup
```

このスクリプトは現在のシェル環境を自動検出し、適切なバージョンを実行します。

### 手動でシェル指定
```bash
# Bash版を明示的に実行
bash tools/setup.sh

# Zsh版を明示的に実行
zsh tools/setup.zsh

# クリーンアップスクリプト実行
./tools/cleanup.zsh --dry-run  # 削除対象確認
./tools/cleanup.zsh           # インタラクティブ削除
./tools/cleanup.zsh --force   # 強制削除

# または簡単なラッパー経由
./cleanup --dry-run
```

## 🔧 スクリプトの特徴

### setup.sh (Bash版)
- **対象**: Bash 4.0以上
- **機能**: 基本的なセットアップ機能
- **互換性**: 最大限の互換性を重視

### setup.zsh (Zsh版)
- **対象**: Zsh 5.0以上
- **機能**: Zsh固有の機能を活用
- **特徴**:
  - `vared`コマンドでより良い入力体験
  - `setopt ERR_EXIT`でより厳密なエラーハンドリング
  - nvmの設定自動読み込み

### cleanup.zsh (クリーンアップ)
- **対象**: Zsh 5.0以上
- **機能**: 不要ファイルの自動削除
- **特徴**:
  - ビルド成果物、一時ファイル、キャッシュの削除
  - Dry-runモードで事前確認可能
  - インタラクティブ確認で安全性確保
  - ファイルサイズ表示と統計情報
  - 保護ファイル機能で重要ファイルを誤削除防止

## 🛠️ 開発者向け情報

### スクリプト追加ガイドライン
1. **命名規則**: `<機能名>.<シェル>`形式
2. **実行権限**: `chmod +x`で実行権限を付与
3. **shebang**: 適切なシェルを指定
4. **エラーハンドリング**: 適切なエラー処理を実装

### 新しいスクリプト例
```bash
# tools/deploy.sh
#!/bin/bash
set -e
echo "デプロイスクリプト（Bash版）"

# tools/deploy.zsh
#!/bin/zsh
setopt ERR_EXIT
echo "デプロイスクリプト（Zsh版）"
```

## 🔍 トラブルシューティング

### 実行権限がない場合
```bash
chmod +x tools/setup.sh tools/setup.zsh
```

### シェルが見つからない場合
```bash
# 利用可能なシェルを確認
cat /etc/shells

# シェルのパスを確認
which bash
which zsh
```

### 未対応シェルの場合
bash版のスクリプトを直接実行してください：
```bash
bash tools/setup.sh
```

---

**関連ドキュメント**:
- [../docs/tpl/point01.md](../docs/tpl/point01.md) - 使用ガイド
- [../docs/development/03-automation-tools.md](../docs/development/03-automation-tools.md) - スクリプト実装記録
- [../docs/development/06-tools-restructure.md](../docs/development/06-tools-restructure.md) - ツール構造改善記録
