#!/bin/bash

# === Fetch and Source Remote Config ===
CONFIG_URL="https://raw.githubusercontent.com/skwel-private/build-topaz/refs/heads/main/upload.config"
CONFIG_FILE="/tmp/upload.config"

curl -s "$CONFIG_URL" -o "$CONFIG_FILE"

if [[ ! -s "$CONFIG_FILE" ]]; then
    echo "❌ Failed to download config file or it's empty."
    exit 1
fi

# Source the config
source "$CONFIG_FILE"

# Check if PIXELDRAIN_API_KEY is set
if [[ -z "$PIXELDRAIN_API_KEY" ]]; then
    echo "❌ PixelDrain API key not set in upload.config."
    exit 1
fi

# === Track start time ===
BUILD_START=$(date +%s)

# === Find the ZIP file (excluding ones with 'ota' in the name) ===
ZIP_FILE=$(find "$ZIP_DIR" -maxdepth 1 -type f -iname "*.zip" ! -iname "*ota*" | head -n 1)

if [[ -z "$ZIP_FILE" ]]; then
    echo "❌ No ZIP file found in $ZIP_DIR excluding ones with 'ota' in the name."
    exit 1
fi

# Extract device name and filename
DEVICE_NAME=$(basename "$ZIP_DIR")
FILE_NAME=$(basename "$ZIP_FILE")

# Get current time
PHT_TIME=$(TZ=Asia/Manila date +"%Y-%m-%d %I:%M %p %Z")

echo "📦 Found ZIP: $ZIP_FILE"

# === Upload to Gofile ===
echo "⏫ Uploading to Gofile (server: $GOFILE_SERVER)..."
UPLOAD_RESPONSE=$(curl -s -X POST "https://$GOFILE_SERVER.gofile.io/uploadFile" \
  -F "file=@$ZIP_FILE")

DOWNLOAD_URL=$(echo "$UPLOAD_RESPONSE" | jq -r '.data.downloadPage')

if [[ "$DOWNLOAD_URL" == "null" || -z "$DOWNLOAD_URL" ]]; then
    echo "❌ Gofile upload failed. Raw response:"
    echo "$UPLOAD_RESPONSE"
    exit 1
fi

echo "✅ Gofile upload successful!"
echo "🔗 Gofile link: $DOWNLOAD_URL"

# === Upload to PixelDrain using working method ===
echo "⏫ Uploading to PixelDrain..."

RESPONSE=$(curl -s -X POST "https://pixeldrain.com/api/file" \
  -u ":$PIXELDRAIN_API_KEY" \
  -F "file=@$ZIP_FILE")

# Check if it succeeded
SUCCESS=$(echo "$RESPONSE" | jq -r '.success')

if [ "$SUCCESS" = "true" ]; then
  FILE_ID=$(echo "$RESPONSE" | jq -r '.id')
  PIXELDRAIN_URL="https://pixeldrain.com/u/$FILE_ID"
  echo "✅ PixelDrain upload successful!"
  echo "🔗 PixelDrain link: $PIXELDRAIN_URL"
else
  echo "❌ PixelDrain upload failed:"
  echo "$RESPONSE"
  PIXELDRAIN_URL=""
fi

# === Send to Telegram ===
MESSAGE="📤 *Build Uploaded*
📱 Device: \`$DEVICE_NAME\`
📦 Filename: \`$FILE_NAME\`
🔗 [Gofile]($DOWNLOAD_URL)
🪞 [Mirror (PixelDrain)]($PIXELDRAIN_URL)
🕒 $PHT_TIME"

TELEGRAM_API="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"

curl -s -X POST "$TELEGRAM_API" \
  -d chat_id="$CHAT_ID" \
  -d text="$MESSAGE" \
  -d parse_mode="Markdown" > /dev/null

echo "📨 Sent to Telegram!"
