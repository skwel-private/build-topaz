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

# === Upload the file ===
echo "⏫ Uploading to Gofile (server: $GOFILE_SERVER)..."
UPLOAD_RESPONSE=$(curl -s -X POST "https://$GOFILE_SERVER.gofile.io/uploadFile" \
  -F "file=@$ZIP_FILE")

DOWNLOAD_URL=$(echo "$UPLOAD_RESPONSE" | jq -r '.data.downloadPage')

if [[ "$DOWNLOAD_URL" == "null" || -z "$DOWNLOAD_URL" ]]; then
    echo "❌ Upload failed. Raw response:"
    echo "$UPLOAD_RESPONSE"
    exit 1
fi

echo "✅ File uploaded successfully!"
echo "🔗 Download link: $DOWNLOAD_URL"

# === Track end time and calculate build duration ===
BUILD_END=$(date +%s)
BUILD_DURATION=$((BUILD_END - BUILD_START))
DURATION_HUMAN="$(printf '%02dh:%02dm:%02ds\n' $((BUILD_DURATION/3600)) $((BUILD_DURATION%3600/60)) $((BUILD_DURATION%60)))"

# === Send to Telegram ===
MESSAGE="📤 *Build Uploaded*
📱 Device: \`$DEVICE_NAME\`
📦 Filename: \`$FILE_NAME\`
⏱️ Duration: \`$DURATION_HUMAN\`
🔗 [Download Link]($DOWNLOAD_URL)
🕒 $PHT_TIME"

TELEGRAM_API="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"

curl -s -X POST "$TELEGRAM_API" \
  -d chat_id="$CHAT_ID" \
  -d text="$MESSAGE" \
  -d parse_mode="Markdown" > /dev/null

echo "📨 Sent to Telegram!"
