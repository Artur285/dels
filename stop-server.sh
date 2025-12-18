#!/bin/bash

# Script to stop the web server

PORT=8000
PID_FILE="/Users/arturboldacev/dels/server.pid"

# Try to stop using PID file
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null 2>&1; then
        echo "🛑 Stopping server (PID: $PID)..."
        kill $PID
        rm "$PID_FILE"
        echo "✅ Server stopped"
    else
        rm "$PID_FILE"
        echo "⚠️  Server process not found"
    fi
fi

# Also check for any process on the port
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "🛑 Stopping server on port $PORT..."
    lsof -ti:$PORT | xargs kill -9 2>/dev/null
    echo "✅ Server stopped"
else
    echo "ℹ️  No server running on port $PORT"
fi

