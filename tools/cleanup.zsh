#!/bin/zsh

# =================================================================
# Next.js学習テンプレート - 不要ファイル削除スクリプト
# =================================================================
#
# 使用方法:
#   ./cleanup.zsh           # インタラクティブモード
#   ./cleanup.zsh --force   # 強制実行（確認なし）
#   ./cleanup.zsh --dry-run # 削除対象ファイルを表示のみ
#
# 作成日: 2025-10-26
# =================================================================

set -euo pipefail

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 実行モード
DRY_RUN=false
FORCE=false

# コマンドライン引数解析
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    -h|--help)
      echo "使用方法: $0 [OPTIONS]"
      echo ""
      echo "OPTIONS:"
      echo "  --dry-run    削除対象ファイルを表示のみ（実際には削除しない）"
      echo "  --force      確認なしで削除実行"
      echo "  -h, --help   このヘルプを表示"
      echo ""
      echo "削除対象:"
      echo "  - ビルド成果物 (.next/, out/, build/)"
      echo "  - 一時ファイル (*.tmp, *.temp, *.log)"
      echo "  - OS生成ファイル (.DS_Store, Thumbs.db)"
      echo "  - エディタファイル (*.swp, *.swo, *~)"
      echo "  - カバレッジレポート (coverage/)"
      echo "  - キャッシュファイル (.eslintcache, *.tsbuildinfo)"
      exit 0
      ;;
    *)
      echo -e "${RED}エラー: 不明なオプション '$1'${NC}"
      echo "使用方法については '$0 --help' を参照してください"
      exit 1
      ;;
  esac
done

# プロジェクトルートディレクトリかチェック
# スクリプトがtools/ディレクトリにある場合、親ディレクトリをチェック
SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
if [[ "$(basename "$SCRIPT_DIR")" == "tools" ]]; then
  PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
  cd "$PROJECT_ROOT"
fi

if [[ ! -f "package.json" ]] || [[ ! -f "next.config.ts" ]]; then
  echo -e "${RED}エラー: Next.jsプロジェクトのルートディレクトリで実行してください${NC}"
  echo -e "${RED}現在のディレクトリ: $(pwd)${NC}"
  exit 1
fi

echo -e "${BLUE}🧹 Next.js学習テンプレート - 不要ファイル削除スクリプト${NC}"
echo -e "${BLUE}===================================================${NC}"

# 削除対象ファイル・ディレクトリのリスト
CLEANUP_PATTERNS=(
  # ビルド成果物
  ".next"
  "out"
  "build"
  "dist"

  # 一時ファイル
  "*.tmp"
  "*.temp"
  "*.log"
  "logs"

  # OS生成ファイル
  ".DS_Store"
  ".DS_Store?"
  "._*"
  ".Spotlight-V100"
  ".Trashes"
  "ehthumbs.db"
  "Thumbs.db"
  "desktop.ini"

  # エディタ・IDE一時ファイル
  "*.swp"
  "*.swo"
  "*~"
  ".vscode/settings.json"
  ".idea"

  # Node.js関連キャッシュ
  ".eslintcache"
  "*.tsbuildinfo"
  ".turbo"

  # テスト・カバレッジ
  "coverage"
  ".nyc_output"
  "junit.xml"

  # Docker関連一時ファイル
  ".docker/tmp"

  # パッケージマネージャーキャッシュ（注意深く）
  "npm-debug.log*"
  "yarn-debug.log*"
  "yarn-error.log*"
  ".pnpm-debug.log*"
)

# 保護するファイル・ディレクトリ（削除してはいけない）
PROTECTED_PATTERNS=(
  "node_modules"
  ".git"
  ".env*"
  "package.json"
  "package-lock.json"
  "yarn.lock"
  "pnpm-lock.yaml"
)

# 削除対象ファイルを検索する関数
find_cleanup_files() {
  local files_found=()

  for pattern in "${CLEANUP_PATTERNS[@]}"; do
    # ディレクトリとファイルを分けて検索
    if [[ "$pattern" == *"*"* ]]; then
      # ワイルドカード付きパターン（ファイル）
      while IFS= read -r -d '' file; do
        files_found+=("$file")
      done < <(find . -maxdepth 3 -name "$pattern" -type f -print0 2>/dev/null)
    else
      # 固定パターン（主にディレクトリ）
      if [[ -e "$pattern" ]]; then
        files_found+=("$pattern")
      fi
    fi
  done

  # 保護対象を除外
  local filtered_files=()
  for file in "${files_found[@]}"; do
    local is_protected=false
    for protected in "${PROTECTED_PATTERNS[@]}"; do
      if [[ "$file" == *"$protected"* ]]; then
        is_protected=true
        break
      fi
    done

    if [[ "$is_protected" == false ]]; then
      filtered_files+=("$file")
    fi
  done

  printf '%s\n' "${filtered_files[@]}"
}

# ファイルサイズを人間に読みやすい形式に変換
human_readable_size() {
  local size=$1
  if (( size >= 1073741824 )); then
    printf "%.1fGB" $((size / 1073741824.0))
  elif (( size >= 1048576 )); then
    printf "%.1fMB" $((size / 1048576.0))
  elif (( size >= 1024 )); then
    printf "%.1fKB" $((size / 1024.0))
  else
    printf "%dB" $size
  fi
}

# ファイル削除関数
remove_file() {
  local file="$1"

  if [[ "$DRY_RUN" == true ]]; then
    if [[ -d "$file" ]]; then
      local size=$(du -sb "$file" 2>/dev/null | cut -f1 || echo "0")
      echo -e "${YELLOW}[DRY-RUN] ディレクトリを削除: $file ($(human_readable_size $size))${NC}"
    else
      local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
      echo -e "${YELLOW}[DRY-RUN] ファイルを削除: $file ($(human_readable_size $size))${NC}"
    fi
    return 0
  fi

  if [[ -d "$file" ]]; then
    local size=$(du -sb "$file" 2>/dev/null | cut -f1 || echo "0")
    echo -e "${GREEN}✓ ディレクトリを削除: $file ($(human_readable_size $size))${NC}"
    rm -rf "$file"
  elif [[ -f "$file" ]]; then
    local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
    echo -e "${GREEN}✓ ファイルを削除: $file ($(human_readable_size $size))${NC}"
    rm -f "$file"
  fi
}

# メイン処理
main() {
  echo "🔍 削除対象ファイルを検索中..."

  local cleanup_files=($(find_cleanup_files))

  if [[ ${#cleanup_files[@]} -eq 0 ]]; then
    echo -e "${GREEN}✨ 削除対象のファイルは見つかりませんでした！${NC}"
    echo "プロジェクトは既にクリーンな状態です。"
    exit 0
  fi

  echo -e "\n${YELLOW}📁 削除対象ファイル (${#cleanup_files[@]}個):${NC}"

  local total_size=0
  for file in "${cleanup_files[@]}"; do
    if [[ -d "$file" ]]; then
      local size=$(du -sb "$file" 2>/dev/null | cut -f1 || echo "0")
      echo -e "  📂 $file ($(human_readable_size $size))"
    else
      local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
      echo -e "  📄 $file ($(human_readable_size $size))"
    fi
    total_size=$((total_size + size))
  done

  echo -e "\n${BLUE}💾 合計削除サイズ: $(human_readable_size $total_size)${NC}"

  # DRY-RUNモードの場合はここで終了
  if [[ "$DRY_RUN" == true ]]; then
    echo -e "\n${YELLOW}[DRY-RUN] 実際の削除は行われませんでした${NC}"
    echo "実際に削除するには '--force' オプションを使用するか、オプションなしで実行してください"
    exit 0
  fi

  # 強制モードでない場合は確認
  if [[ "$FORCE" == false ]]; then
    echo -e "\n${YELLOW}⚠️  これらのファイルを削除しますか？${NC}"
    echo -e "${YELLOW}   (削除されたファイルは復元できません)${NC}"
    echo ""
    echo "y/Y: 削除実行"
    echo "n/N: キャンセル"
    echo "l/L: ファイル一覧を再表示"
    echo ""

    while true; do
      echo -n "選択してください [y/n/l]: "
      read choice
      case $choice in
        [Yy]* )
          break
          ;;
        [Nn]* )
          echo -e "${YELLOW}削除をキャンセルしました${NC}"
          exit 0
          ;;
        [Ll]* )
          echo -e "\n${YELLOW}削除対象ファイル一覧:${NC}"
          for file in "${cleanup_files[@]}"; do
            echo "  - $file"
          done
          echo ""
          ;;
        * )
          echo "y、n、またはlを入力してください"
          ;;
      esac
    done
  fi

  # 削除実行
  echo -e "\n${GREEN}🗑️  ファイル削除を開始します...${NC}"

  local deleted_count=0
  local error_count=0

  for file in "${cleanup_files[@]}"; do
    if remove_file "$file"; then
      deleted_count=$((deleted_count + 1))
    else
      error_count=$((error_count + 1))
      echo -e "${RED}✗ 削除に失敗: $file${NC}"
    fi
  done

  echo -e "\n${GREEN}✨ クリーンアップが完了しました！${NC}"
  echo -e "${GREEN}   削除されたファイル: ${deleted_count}個${NC}"

  if [[ $error_count -gt 0 ]]; then
    echo -e "${RED}   エラー: ${error_count}個${NC}"
  fi

  echo -e "${GREEN}   解放されたディスク容量: $(human_readable_size $total_size)${NC}"

  # 最終状態表示
  echo -e "\n${BLUE}📊 クリーンアップ後の状態:${NC}"
  if command -v du >/dev/null 2>&1; then
    local project_size=$(du -sh . 2>/dev/null | cut -f1 || echo "不明")
    echo -e "   プロジェクトサイズ: $project_size"
  fi

  if [[ -d "node_modules" ]]; then
    local node_modules_size=$(du -sh node_modules 2>/dev/null | cut -f1 || echo "不明")
    echo -e "   node_modules: $node_modules_size"
  fi
}

# スクリプト実行
main "$@"
