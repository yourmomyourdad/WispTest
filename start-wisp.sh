#!/bin/bash

PORT=8081
SCRAMJET_DIR="$(cd "$(dirname "$0")/Scramjet-App" && pwd)"

echo "=========================================="
echo "         SCRAMJET + CLOUDFLARE"
echo "=========================================="
echo

echo "Checking Scramjet-App..."

if [ ! -f "$SCRAMJET_DIR/package.json" ]; then
    echo "ERROR: Scramjet-App was not found."
    exit 1
fi

echo
echo "Installing dependencies..."
cd "$SCRAMJET_DIR"
npm install

if [ $? -ne 0 ]; then
    echo
    echo "ERROR: npm install failed."
    exit 1
fi

echo
echo "Dependencies ready!"
echo

echo "Starting Scramjet on port $PORT..."

PORT=$PORT npm start > /tmp/scramjet.log 2>&1 &
SCRAMJET_PID=$!

echo "Scramjet PID: $SCRAMJET_PID"
echo "Waiting for Scramjet..."

until curl -s --max-time 2 "http://127.0.0.1:$PORT/" > /dev/null 2>&1; do
    sleep 1

    if ! kill -0 "$SCRAMJET_PID" 2>/dev/null; then
        echo
        echo "ERROR: Scramjet stopped unexpectedly."
        echo
        cat /tmp/scramjet.log
        exit 1
    fi
done

echo "Scramjet is ready!"
echo

echo "=========================================="
echo "       STARTING CLOUDFLARE TUNNEL"
echo "=========================================="
echo

cloudflared tunnel \
    --protocol http2 \
    --url "http://127.0.0.1:$PORT"
