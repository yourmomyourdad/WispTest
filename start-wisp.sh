#!/bin/bash

set -e

PORT=8081
BASE="$(cd "$(dirname "$0")" && pwd)"
SCRAMJET="$BASE/Scramjet-App"
ZIP="$BASE/scramjet.zip"

echo "=========================================="
echo "     SCRAMJET + CLOUDFLARE INSTALLER"
echo "=========================================="
echo

# ==========================================
# Check Node.js
# ==========================================

echo "Checking Node.js..."

if ! command -v node >/dev/null 2>&1; then
    echo "ERROR: Node.js is not installed."
    exit 1
fi

node --version
npm --version
echo

# ==========================================
# Check cloudflared
# ==========================================

# ==========================================
# Check / Install cloudflared
# ==========================================

echo "Checking cloudflared..."

if ! command -v cloudflared >/dev/null 2>&1; then
    echo "cloudflared not found!"
    echo "Installing cloudflared..."

    sudo apt-get update
    sudo apt-get install -y curl gnupg

    echo "Adding Cloudflare repository..."

    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
        | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

    echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared noble main" \
        | sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null

    sudo apt-get update
    sudo apt-get install -y cloudflared

    if ! command -v cloudflared >/dev/null 2>&1; then
        echo "ERROR: cloudflared installation failed."
        exit 1
    fi

    echo "cloudflared installed!"
else
    echo "cloudflared already installed!"
fi

cloudflared --version
echo

# ==========================================
# Download Scramjet-App
# ==========================================

if [ -f "$SCRAMJET/package.json" ]; then
    echo "Scramjet-App already exists."
else
    echo "Scramjet-App not found."
    echo "Downloading Scramjet-App..."

    curl -L \
        "https://github.com/MercuryWorkshop/Scramjet-App/archive/refs/heads/main.zip" \
        -o "$ZIP"

    echo "Extracting..."

    unzip -q "$ZIP" -d "$BASE"

    mv "$BASE/Scramjet-App-main" "$SCRAMJET"

    rm "$ZIP"

    echo "Scramjet-App downloaded!"
fi

echo

# ==========================================
# Install dependencies
# ==========================================

echo "=========================================="
echo "       INSTALLING DEPENDENCIES"
echo "=========================================="
echo

cd "$SCRAMJET"

npm install

echo
echo "Dependencies ready!"
echo

# ==========================================
# Start Scramjet
# ==========================================

echo "=========================================="
echo "          STARTING SCRAMJET"
echo "=========================================="
echo

echo "Starting Scramjet on port $PORT..."

PORT="$PORT" npm start > /tmp/scramjet.log 2>&1 &
SCRAMJET_PID=$!

echo "Scramjet PID: $SCRAMJET_PID"
echo "Waiting for Scramjet..."

# ==========================================
# Wait for Scramjet
# ==========================================

while ! curl -s --max-time 2 "http://127.0.0.1:$PORT/" >/dev/null 2>&1
do
    if ! kill -0 "$SCRAMJET_PID" 2>/dev/null; then
        echo
        echo "ERROR: Scramjet stopped unexpectedly."
        echo
        cat /tmp/scramjet.log
        exit 1
    fi

    sleep 1
done

echo
echo "Scramjet is ready!"
echo

# ==========================================
# Start Cloudflare
# ==========================================

echo "=========================================="
echo "       STARTING CLOUDFLARE TUNNEL"
echo "=========================================="
echo

cloudflared tunnel \
    --protocol http2 \
    --url "http://127.0.0.1:$PORT"
