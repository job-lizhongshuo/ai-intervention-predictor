#!/bin/bash

if [ -f backend.pid ]; then
    PID=$(cat backend.pid)
    kill $PID 2>/dev/null && echo "✓ 后端已停止 (PID: $PID)" || echo "进程不存在"
    rm backend.pid
else
    echo "❌ 没有运行的服务"
fi
