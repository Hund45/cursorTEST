#!/bin/bash

echo "🎵 Starting Crystal Waves Server..."

# Try Node.js first
if command -v node &> /dev/null; then
    echo "✅ Using Node.js server"
    node server.js
# Try Python 3
elif command -v python3 &> /dev/null; then
    echo "✅ Using Python 3 server"
    python3 -m http.server 3000
# Try Python 2
elif command -v python &> /dev/null; then
    echo "✅ Using Python 2 server"
    python -m SimpleHTTPServer 3000
else
    echo "❌ No suitable server found!"
    echo "Please install Node.js or Python to run the server"
    exit 1
fi