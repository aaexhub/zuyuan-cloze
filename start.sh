#!/bin/bash
# 祖源选词填空练习系统启动脚本
# 端口: 8890

PORT=8890
DIR="$(cd "$(dirname "$0")" && pwd)"

get_local_ip() {
    local ip=""
    ip=$(ifconfig 2>/dev/null | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
    if [ -z "$ip" ]; then
        ip=$(ipconfig getifaddr en0 2>/dev/null)
    fi
    if [ -z "$ip" ]; then
        ip="查看系统偏好设置→网络"
    fi
    echo "$ip"
}

start() {
    if lsof -i :$PORT > /dev/null 2>&1; then
        echo "⚠️  端口 $PORT 已被占用，正在停止旧进程..."
        stop
        sleep 1
    fi
    
    echo "🚀 启动选词填空练习系统..."
    cd "$DIR"
    python3 -m http.server $PORT > /dev/null 2>&1 &
    PID=$!
    echo $PID > /tmp/cloze-app.pid
    
    sleep 1
    if lsof -i :$PORT > /dev/null 2>&1; then
        echo "✅ 系统已启动"
        echo "📱 访问地址:"
        echo "   本机: http://localhost:$PORT"
        echo "   局域网: http://$(get_local_ip):$PORT"
        echo "🛑 停止命令: $0 stop"
    else
        echo "❌ 启动失败"
    fi
}

stop() {
    if [ -f /tmp/cloze-app.pid ]; then
        PID=$(cat /tmp/cloze-app.pid)
        kill $PID 2>/dev/null
        rm /tmp/cloze-app.pid
    fi
    pkill -f "http.server $PORT" 2>/dev/null
    echo "✅ 已停止"
}

status() {
    if lsof -i :$PORT > /dev/null 2>&1; then
        echo "✅ 运行中 (端口 $PORT)"
        echo "📱 http://localhost:$PORT"
    else
        echo "⭕ 未运行"
    fi
}

case "$1" in
    start)   start ;;
    stop)    stop ;;
    status)  status ;;
    restart) stop; sleep 1; start ;;
    *)       echo "用法: $0 {start|stop|status|restart}" ;;
esac
