#!/bin/bash

# Script to start and keep the web server running

PORT=8000
DIR="/Users/arturboldacev/dels"

cd "$DIR"

# Check if port is already in use
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "✅ Server is already running on port $PORT"
    echo "📍 Access your site at: http://localhost:$PORT"
    exit 0
fi

echo "🚀 Starting web server on port $PORT..."
echo "📍 Access your site at: http://localhost:$PORT"
echo "📍 Homepage: http://localhost:$PORT/index.html"
echo "📍 Properties: http://localhost:$PORT/properties.html"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the server
python3 -m http.server $PORT

