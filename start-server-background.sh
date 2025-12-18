#!/bin/bash

# Script to start web server in background and keep it running

PORT=8000
DIR="/Users/arturboldacev/dels"
LOG_FILE="$DIR/server.log"
PID_FILE="$DIR/server.pid"

cd "$DIR"

# Check if server is already running
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null 2>&1; then
        echo "✅ Server is already running (PID: $PID)"
        echo "📍 Access your site at: http://localhost:$PORT"
        exit 0
    else
        rm "$PID_FILE"
    fi
fi

# Check if port is in use
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "⚠️  Port $PORT is already in use"
    echo "   Stopping existing server..."
    lsof -ti:$PORT | xargs kill -9 2>/dev/null
    sleep 1
fi

echo "🚀 Starting web server in background on port $PORT..."
echo "📍 Access your site at: http://localhost:$PORT"
echo "📍 Logs: $LOG_FILE"
echo ""

# Start server in background
nohup python3 -m http.server $PORT > "$LOG_FILE" 2>&1 &
SERVER_PID=$!

# Save PID
echo $SERVER_PID > "$PID_FILE"

echo "✅ Server started successfully (PID: $SERVER_PID)"
echo ""
echo "To stop the server, run:"
echo "  ./stop-server.sh"
echo "or"
echo "  kill $SERVER_PID"

