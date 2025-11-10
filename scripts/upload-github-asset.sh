#!/bin/bash
# Upload an image (JPG/PNG) to GitHub's asset upload endpoint
# Usage: ./upload-github-asset.sh <image-path> <asset-id> [owner] [repo]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Arguments
IMAGE_PATH="${1}"
ASSET_ID="${2}"
OWNER="${3:-austenstone}"
REPO="${4:-actions-playground}"

# Validate arguments
if [[ -z "$IMAGE_PATH" ]] || [[ -z "$ASSET_ID" ]]; then
    echo -e "${RED}❌ Usage: $0 <image-path> <asset-id> [owner] [repo]${NC}"
    echo -e "${GRAY}Example: $0 screenshot.png 512420494${NC}"
    exit 1
fi

# Validate file exists
if [[ ! -f "$IMAGE_PATH" ]]; then
    echo -e "${RED}❌ File not found: $IMAGE_PATH${NC}"
    exit 1
fi

# Validate image format
extension="${IMAGE_PATH##*.}"
extension="${extension,,}" # Convert to lowercase

if [[ ! "$extension" =~ ^(jpg|jpeg|png)$ ]]; then
    echo -e "${RED}❌ Only JPG and PNG images are supported. Got: .$extension${NC}"
    exit 1
fi

# Determine MIME type
if [[ "$extension" == "png" ]]; then
    MIME_TYPE="image/png"
else
    MIME_TYPE="image/jpeg"
fi

# Get file info
FILE_NAME=$(basename "$IMAGE_PATH")
FILE_SIZE=$(stat -f%z "$IMAGE_PATH" 2>/dev/null || stat -c%s "$IMAGE_PATH" 2>/dev/null)
FILE_SIZE_KB=$(echo "scale=2; $FILE_SIZE / 1024" | bc)

echo -e "${CYAN}📸 Uploading image: $FILE_NAME${NC}"
echo -e "${GRAY}   Size: ${FILE_SIZE_KB} KB${NC}"
echo -e "${GRAY}   Type: $MIME_TYPE${NC}"
echo ""

# Generate boundary for multipart form data
BOUNDARY="----WebKitFormBoundary$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | head -c 16)"

# Get authenticity token
echo -e "${YELLOW}🔑 Fetching authenticity token...${NC}"
TOKEN_PAGE=$(curl -s "https://github.com/$OWNER/$REPO/issues" \
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
    -c /tmp/github_cookies.txt)

AUTHENTICITY_TOKEN=$(echo "$TOKEN_PAGE" | grep -o 'name="authenticity_token"[^>]*value="[^"]*"' | grep -o 'value="[^"]*"' | cut -d'"' -f2 | head -n1)

if [[ -z "$AUTHENTICITY_TOKEN" ]]; then
    echo -e "${RED}❌ Could not extract authenticity token${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Got authenticity token${NC}"

# Create multipart form data
TEMP_FILE=$(mktemp)
cat > "$TEMP_FILE" << EOF
--$BOUNDARY
Content-Disposition: form-data; name="authenticity_token"

$AUTHENTICITY_TOKEN
--$BOUNDARY
Content-Disposition: form-data; name="file"; filename="$FILE_NAME"
Content-Type: $MIME_TYPE

EOF

# Append binary file content
cat "$IMAGE_PATH" >> "$TEMP_FILE"

# Append closing boundary
echo -e "\r\n--$BOUNDARY--\r" >> "$TEMP_FILE"

# Upload the image
echo -e "${YELLOW}⬆️  Uploading to GitHub asset endpoint...${NC}"
UPLOAD_URL="https://github.com/upload/assets/$ASSET_ID"

RESPONSE=$(curl -X PUT "$UPLOAD_URL" \
    -H "Accept: application/json" \
    -H "Content-Type: multipart/form-data; boundary=$BOUNDARY" \
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36" \
    -H "X-Requested-With: XMLHttpRequest" \
    -H "Referer: https://github.com/$OWNER/$REPO/issues" \
    -H "sec-ch-ua: \"Chromium\";v=\"142\", \"Google Chrome\";v=\"142\", \"Not_A Brand\";v=\"99\"" \
    -H "sec-ch-ua-mobile: ?0" \
    -H "sec-ch-ua-platform: \"Windows\"" \
    -H "Origin: https://github.com" \
    -b /tmp/github_cookies.txt \
    --data-binary "@$TEMP_FILE" \
    -w "\n%{http_code}" \
    -s)

# Extract status code
STATUS_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | head -n-1)

# Clean up
rm -f "$TEMP_FILE" /tmp/github_cookies.txt

if [[ "$STATUS_CODE" =~ ^2[0-9]{2}$ ]]; then
    echo -e "${GREEN}✅ Upload successful!${NC}"
    echo ""
    echo -e "${CYAN}📋 Response:${NC}"
    echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"
    
    # Extract asset URL if available
    ASSET_URL=$(echo "$RESPONSE_BODY" | jq -r '.asset_url // empty' 2>/dev/null)
    if [[ -n "$ASSET_URL" ]]; then
        echo ""
        echo -e "${GREEN}🔗 Asset URL: $ASSET_URL${NC}"
    fi
else
    echo -e "${RED}❌ Upload failed with status code: $STATUS_CODE${NC}"
    echo -e "${RED}Response: $RESPONSE_BODY${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Done!${NC}"
