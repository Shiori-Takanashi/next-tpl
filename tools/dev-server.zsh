#!/usr/bin/env zsh

# 開発サーバー管理ツール - ローカル/Docker開発環境管理
# Next.js学習テンプレート用

setopt ERR_EXIT
autoload -U colors && colors

# プロジェクトルート取得
PROJECT_ROOT=${0:A:h:h}
cd "$PROJECT_ROOT"

# ユーティリティ関数
print_info() {
    print -P "%F{blue}ℹ️  $1%f"
}

print_success() {
    print -P "%F{green}✅ $1%f"
}

print_error() {
    print -P "%F{red}❌ $1%f"
}

print_warning() {
    print -P "%F{yellow}⚠️  $1%f"
}

print_step() {
    print -P "%F{cyan}🔄 $1%f"
}

# PIDファイルパス
PID_FILE="/tmp/next-dev-server.pid"
DOCKER_COMPOSE_FILE="docker-compose.yml"

# ヘルプ表示
show_help() {
    print -P "%F{cyan}🖥️  開発サーバー管理ツール%f"
    echo ""
    echo "使用方法: ./tools/dev-server.zsh [コマンド] [オプション]"
    echo ""
    echo "📋 利用可能なコマンド:"
    echo ""
    echo "  start, s              開発サーバーを起動"
    echo "  stop, st              開発サーバーを停止"
    echo "  restart, r            開発サーバーを再起動"
    echo "  status, stat          サーバーの状態を確認"
    echo "  logs, l               サーバーログを表示"
    echo "  docker-start, ds      Docker開発サーバーを起動"
    echo "  docker-stop, dst      Docker開発サーバーを停止"
    echo "  docker-restart, dr    Docker開発サーバーを再起動"
    echo "  docker-logs, dl       Dockerログを表示"
    echo "  open, o               ブラウザでサーバーを開く"
    echo "  health, h             ヘルスチェック実行"
    echo "  monitor, m            リアルタイム監視"
    echo "  clean, c              開発環境をクリーンアップ"
    echo ""
    echo "🎯 オプション:"
    echo "  --port [port]         ポート番号指定 (デフォルト: 3000)"
    echo "  --host [host]         ホスト指定 (デフォルト: localhost)"
    echo "  --background, -b      バックグラウンドで起動"
    echo "  --watch, -w           ファイル変更監視を有効化"
    echo "  --verbose, -v         詳細ログ出力"
    echo "  --turbo              Turbopackを使用"
    echo ""
    echo "🎯 使用例:"
    echo "  ./tools/dev-server.zsh start --port 3001   # ポート3001で起動"
    echo "  ./tools/dev-server.zsh docker-start -b     # Dockerをバックグラウンドで起動"
    echo "  ./tools/dev-server.zsh monitor             # リアルタイム監視"
    echo "  ./tools/dev-server.zsh health              # ヘルスチェック"
}

# ポート使用状況チェック
check_port() {
    local port="$1"
    
    if command -v lsof >/dev/null 2>&1; then
        lsof -ti:$port >/dev/null 2>&1
    elif command -v ss >/dev/null 2>&1; then
        ss -tuln | grep ":$port " >/dev/null 2>&1
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tuln | grep ":$port " >/dev/null 2>&1
    else
        # 基本的な接続テスト
        timeout 1 bash -c "</dev/tcp/localhost/$port" 2>/dev/null
    fi
}

# プロセス終了
kill_process_on_port() {
    local port="$1"
    
    if command -v lsof >/dev/null 2>&1; then
        local pid=$(lsof -ti:$port 2>/dev/null)
        if [[ -n "$pid" ]]; then
            kill $pid 2>/dev/null || kill -9 $pid 2>/dev/null
            print_success "ポート $port のプロセス (PID: $pid) を終了しました"
            return 0
        fi
    fi
    
    return 1
}

# 開発サーバー起動
start_dev_server() {
    local port="$1"
    local host="$2"
    local background="$3"
    local turbo="$4"
    local verbose="$5"
    
    # ポート使用状況チェック
    if check_port "$port"; then
        print_warning "ポート $port は既に使用されています"
        read -q "?既存のプロセスを終了しますか? (y/N): " && {
            echo
            kill_process_on_port "$port"
            sleep 2
        } || {
            echo
            print_error "サーバーの起動をキャンセルしました"
            return 1
        }
    fi
    
    # 依存関係チェック
    if [[ ! -d "node_modules" ]]; then
        print_warning "node_modules が見つかりません。依存関係をインストールしています..."
        npm install || {
            print_error "依存関係のインストールに失敗しました"
            return 1
        }
    fi
    
    print_step "開発サーバーを起動しています..."
    print_info "URL: http://$host:$port"
    
    # 起動コマンド構築
    local dev_cmd="npm run dev"
    local env_vars="PORT=$port HOST=$host"
    
    if [[ "$turbo" == "true" ]]; then
        env_vars="$env_vars TURBOPACK=1"
        print_info "Turbopackモードで起動します"
    fi
    
    if [[ "$background" == "true" ]]; then
        print_info "バックグラウンドで起動します"
        print_warning "停止するには: ./tools/dev-server.zsh stop"
        
        # バックグラウンド起動
        nohup env $env_vars $dev_cmd > "/tmp/next-dev-server.log" 2>&1 &
        local pid=$!
        echo $pid > "$PID_FILE"
        
        # 起動確認
        sleep 3
        if check_port "$port"; then
            print_success "開発サーバーが起動しました (PID: $pid)"
            print_info "ログファイル: /tmp/next-dev-server.log"
        else
            print_error "サーバーの起動に失敗しました"
            cat /tmp/next-dev-server.log
            return 1
        fi
    else
        print_warning "Ctrl+C で停止できます"
        env $env_vars $dev_cmd
    fi
}

# 開発サーバー停止
stop_dev_server() {
    local port="$1"
    
    # PIDファイルから停止
    if [[ -f "$PID_FILE" ]]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 $pid 2>/dev/null; then
            print_step "開発サーバーを停止しています... (PID: $pid)"
            kill $pid 2>/dev/null || kill -9 $pid 2>/dev/null
            rm -f "$PID_FILE"
            print_success "開発サーバーを停止しました"
        else
            print_warning "PIDファイルに記録されたプロセスは既に終了しています"
            rm -f "$PID_FILE"
        fi
    fi
    
    # ポートベースで停止
    if check_port "$port"; then
        print_step "ポート $port のプロセスを停止しています..."
        kill_process_on_port "$port"
    else
        print_info "ポート $port で動作しているプロセスはありません"
    fi
}

# サーバー状態確認
check_server_status() {
    local port="$1"
    local host="$2"
    
    print_info "サーバー状態をチェックしています..."
    echo ""
    
    # ポート使用状況
    if check_port "$port"; then
        print_success "ポート $port: 使用中"
        
        # PIDファイル確認
        if [[ -f "$PID_FILE" ]]; then
            local pid=$(cat "$PID_FILE")
            if kill -0 $pid 2>/dev/null; then
                print_info "プロセスID: $pid"
                
                # プロセス情報
                if command -v ps >/dev/null 2>&1; then
                    local process_info=$(ps -p $pid -o pid,ppid,cmd --no-headers 2>/dev/null)
                    if [[ -n "$process_info" ]]; then
                        print_info "プロセス情報: $process_info"
                    fi
                fi
            else
                print_warning "PIDファイルは存在しますが、プロセスは動作していません"
                rm -f "$PID_FILE"
            fi
        fi
        
        # HTTP接続テスト
        print_step "HTTP接続をテストしています..."
        if curl -s "http://$host:$port" >/dev/null 2>&1; then
            print_success "HTTP接続: OK"
            
            # レスポンス時間測定
            local response_time=$(curl -o /dev/null -s -w "%{time_total}" "http://$host:$port" 2>/dev/null)
            print_info "レスポンス時間: ${response_time}秒"
        else
            print_warning "HTTP接続: NG (サーバーが応答しません)"
        fi
    else
        print_warning "ポート $port: 未使用"
        print_info "サーバーは起動していません"
    fi
    
    # リソース使用状況
    echo ""
    print_info "システムリソース:"
    
    # CPU使用率
    if command -v top >/dev/null 2>&1; then
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
        print_info "CPU使用率: $cpu_usage"
    fi
    
    # メモリ使用状況
    if command -v free >/dev/null 2>&1; then
        local memory_info=$(free -h | grep Mem | awk '{print $3"/"$2}')
        print_info "メモリ使用量: $memory_info"
    fi
}

# Docker開発サーバー起動
start_docker_dev() {
    local background="$1"
    local verbose="$2"
    
    if [[ ! -f "$DOCKER_COMPOSE_FILE" ]]; then
        print_error "docker-compose.yml が見つかりません"
        return 1
    fi
    
    print_step "Docker開発サーバーを起動しています..."
    
    if [[ "$background" == "true" ]]; then
        print_info "バックグラウンドで起動します"
        docker-compose up -d next-tpl-dev
        
        # 起動確認
        sleep 5
        if docker-compose ps next-tpl-dev | grep -q "Up"; then
            print_success "Docker開発サーバーが起動しました"
            docker-compose ps next-tpl-dev
        else
            print_error "Docker開発サーバーの起動に失敗しました"
            docker-compose logs next-tpl-dev
            return 1
        fi
    else
        print_warning "Ctrl+C で停止できます"
        docker-compose up next-tpl-dev
    fi
}

# Docker開発サーバー停止
stop_docker_dev() {
    print_step "Docker開発サーバーを停止しています..."
    
    docker-compose stop next-tpl-dev
    docker-compose rm -f next-tpl-dev
    
    print_success "Docker開発サーバーを停止しました"
}

# ログ表示
show_logs() {
    local mode="$1"
    local follow="$2"
    
    case "$mode" in
        "docker")
            if [[ "$follow" == "true" ]]; then
                print_info "Dockerログをリアルタイムで表示します (Ctrl+C で停止)"
                docker-compose logs -f next-tpl-dev
            else
                docker-compose logs --tail=50 next-tpl-dev
            fi
            ;;
        *)
            local log_file="/tmp/next-dev-server.log"
            if [[ -f "$log_file" ]]; then
                if [[ "$follow" == "true" ]]; then
                    print_info "ログをリアルタイムで表示します (Ctrl+C で停止)"
                    tail -f "$log_file"
                else
                    tail -50 "$log_file"
                fi
            else
                print_warning "ログファイルが見つかりません: $log_file"
            fi
            ;;
    esac
}

# ブラウザで開く
open_browser() {
    local port="$1"
    local host="$2"
    local url="http://$host:$port"
    
    if ! check_port "$port"; then
        print_error "サーバーがポート $port で起動していません"
        return 1
    fi
    
    print_info "ブラウザでサーバーを開いています: $url"
    
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$url" >/dev/null 2>&1 &
    elif command -v open >/dev/null 2>&1; then
        open "$url" >/dev/null 2>&1 &
    elif command -v start >/dev/null 2>&1; then
        start "$url" >/dev/null 2>&1 &
    else
        print_warning "ブラウザを自動で開けません。手動で $url にアクセスしてください"
    fi
}

# ヘルスチェック
health_check() {
    local port="$1"
    local host="$2"
    
    print_info "ヘルスチェックを実行しています..."
    echo ""
    
    local checks_passed=0
    local total_checks=5
    
    # 1. ポートチェック
    print_step "1. ポート可用性チェック"
    if check_port "$port"; then
        print_success "✓ ポート $port は使用中"
        ((checks_passed++))
    else
        print_error "✗ ポート $port は使用されていません"
    fi
    
    # 2. HTTP接続チェック
    print_step "2. HTTP接続チェック"
    if curl -s "http://$host:$port" >/dev/null 2>&1; then
        print_success "✓ HTTP接続成功"
        ((checks_passed++))
    else
        print_error "✗ HTTP接続失敗"
    fi
    
    # 3. レスポンス内容チェック
    print_step "3. レスポンス内容チェック"
    local response=$(curl -s "http://$host:$port" 2>/dev/null)
    if echo "$response" | grep -q "<!DOCTYPE html>\|<html"; then
        print_success "✓ HTMLレスポンス確認"
        ((checks_passed++))
    else
        print_error "✗ 有効なHTMLレスポンスがありません"
    fi
    
    # 4. JavaScript/CSSアセットチェック
    print_step "4. アセットチェック"
    if echo "$response" | grep -q "_next/static\|/static"; then
        print_success "✓ Next.jsアセット確認"
        ((checks_passed++))
    else
        print_warning "? Next.jsアセットが見つかりません"
    fi
    
    # 5. パフォーマンスチェック
    print_step "5. パフォーマンスチェック"
    local response_time=$(curl -o /dev/null -s -w "%{time_total}" "http://$host:$port" 2>/dev/null)
    if (( $(echo "$response_time < 2.0" | bc -l 2>/dev/null || echo 1) )); then
        print_success "✓ レスポンス時間: ${response_time}秒"
        ((checks_passed++))
    else
        print_warning "? レスポンス時間が遅い: ${response_time}秒"
    fi
    
    echo ""
    print_info "ヘルスチェック結果: $checks_passed/$total_checks"
    
    if [[ $checks_passed -eq $total_checks ]]; then
        print_success "すべてのチェックに合格しました"
    elif [[ $checks_passed -ge $((total_checks - 1)) ]]; then
        print_warning "概ね正常に動作しています"
    else
        print_error "問題が検出されました"
    fi
}

# リアルタイム監視
monitor_server() {
    local port="$1"
    local host="$2"
    
    print_info "リアルタイム監視を開始します (Ctrl+C で停止)"
    echo ""
    
    while true; do
        clear
        print_info "=== 開発サーバー監視 ($(date)) ==="
        echo ""
        
        # 基本ステータス
        if check_port "$port"; then
            print_success "サーバー: 起動中"
            
            # レスポンス時間
            local response_time=$(curl -o /dev/null -s -w "%{time_total}" "http://$host:$port" 2>/dev/null || echo "N/A")
            print_info "レスポンス時間: ${response_time}秒"
        else
            print_error "サーバー: 停止中"
        fi
        
        # システムリソース
        if command -v top >/dev/null 2>&1; then
            echo ""
            print_info "システム使用状況:"
            top -bn1 | head -5
        fi
        
        # 最新ログ (Docker の場合)
        if docker-compose ps next-tpl-dev 2>/dev/null | grep -q "Up"; then
            echo ""
            print_info "最新ログ (Docker):"
            docker-compose logs --tail=3 next-tpl-dev 2>/dev/null
        fi
        
        sleep 5
    done
}

# 開発環境クリーンアップ
clean_dev_env() {
    print_step "開発環境をクリーンアップしています..."
    
    # ローカルサーバー停止
    stop_dev_server "3000"
    
    # Dockerサーバー停止
    stop_docker_dev 2>/dev/null || true
    
    # 一時ファイル削除
    rm -f /tmp/next-dev-server.log
    rm -f "$PID_FILE"
    
    # Next.jsキャッシュクリア
    rm -rf .next/cache 2>/dev/null || true
    
    print_success "開発環境のクリーンアップが完了しました"
}

# メイン処理
main() {
    local command="$1"
    shift
    
    local port="3000"
    local host="localhost"
    local background="false"
    local turbo="false"
    local verbose="false"
    local follow="false"
    
    # オプション解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --port)
                port="$2"
                shift
                ;;
            --host)
                host="$2"
                shift
                ;;
            --background|-b)
                background="true"
                ;;
            --turbo)
                turbo="true"
                ;;
            --verbose|-v)
                verbose="true"
                ;;
            --watch|-w)
                follow="true"
                ;;
            *)
                print_error "不明なオプション: $1"
                return 1
                ;;
        esac
        shift
    done
    
    # コマンド実行
    case "$command" in
        "start"|"s")
            start_dev_server "$port" "$host" "$background" "$turbo" "$verbose"
            ;;
        "stop"|"st")
            stop_dev_server "$port"
            ;;
        "restart"|"r")
            stop_dev_server "$port"
            sleep 2
            start_dev_server "$port" "$host" "$background" "$turbo" "$verbose"
            ;;
        "status"|"stat")
            check_server_status "$port" "$host"
            ;;
        "logs"|"l")
            show_logs "local" "$follow"
            ;;
        "docker-start"|"ds")
            start_docker_dev "$background" "$verbose"
            ;;
        "docker-stop"|"dst")
            stop_docker_dev
            ;;
        "docker-restart"|"dr")
            stop_docker_dev
            sleep 2
            start_docker_dev "$background" "$verbose"
            ;;
        "docker-logs"|"dl")
            show_logs "docker" "$follow"
            ;;
        "open"|"o")
            open_browser "$port" "$host"
            ;;
        "health"|"h")
            health_check "$port" "$host"
            ;;
        "monitor"|"m")
            monitor_server "$port" "$host"
            ;;
        "clean"|"c")
            clean_dev_env
            ;;
        "help"|""|*)
            show_help
            ;;
    esac
}

# スクリプト実行
main "$@"