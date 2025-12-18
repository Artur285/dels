#!/bin/bash

# Script to keep the server running - restarts if it crashes

PORT=8000
DIR="/Users/arturboldacev/dels"
LOG_FILE="$DIR/server.log"
PID_FILE="$DIR/server.pid"

cd "$DIR"

echo "🔄 Starting server with auto-restart..."
echo "📍 Server will restart automatically if it crashes"
echo "📍 Access your site at: http://localhost:$PORT"
echo ""

# Function to start server
start_server() {
    python3 -m http.server $PORT >> "$LOG_FILE" 2>&1 &
    SERVER_PID=$!
    echo $SERVER_PID > "$PID_FILE"
    echo "✅ Server started (PID: $SERVER_PID)"
}

# Start server initially
start_server

# Monitor and restart if needed
while true; do
    sleep 5
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ! ps -p $PID > /dev/null 2>&1; then
            echo "⚠️  Server crashed, restarting..."
            start_server
        fi
    else
        echo "⚠️  PID file missing, restarting server..."
        start_server
    fi
done

