#!/bin/bash

###############################################################################
# Padoo Delivery Server Startup Script
# This script ensures clean server startup with cache busting
###############################################################################

echo "🚀 Starting Padoo Delivery Server..."
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${YELLOW}📁 Working directory: $SCRIPT_DIR${NC}"

# Step 1: Kill all existing PM2 processes
echo -e "\n${YELLOW}🛑 Stopping existing PM2 processes...${NC}"
pm2 delete all 2>/dev/null || true
pm2 kill 2>/dev/null || true

# Step 2: Kill any rogue Node.js processes
echo -e "${YELLOW}🔪 Killing any remaining Node.js processes...${NC}"
pkill -9 node 2>/dev/null || true
sleep 2

# Step 3: Clear PM2 logs
echo -e "${YELLOW}🧹 Clearing PM2 logs...${NC}"
pm2 flush 2>/dev/null || true
rm -rf ~/.pm2/logs/* 2>/dev/null || true

# Step 4: Add cache-busting version to HTML files
echo -e "\n${YELLOW}🔄 Adding cache-busting to static files...${NC}"

# Generate timestamp for cache busting
CACHE_VERSION=$(date +%s)

# Update delivery app index.html
if [ -f "mainapp/delivery/index.html" ]; then
    echo -e "${GREEN}  ✓ Updating mainapp/delivery/index.html${NC}"
    # Remove old cache busting parameters
    sed -i 's/app\.js?v=[0-9]*/app.js/g' mainapp/delivery/index.html
    sed -i 's/translations\.js?v=[0-9]*/translations.js/g' mainapp/delivery/index.html
    # Add new cache busting parameters
    sed -i "s|js/app\.js|js/app.js?v=$CACHE_VERSION|g" mainapp/delivery/index.html
    sed -i "s|js/translations\.js|js/translations.js?v=$CACHE_VERSION|g" mainapp/delivery/index.html
fi

# Update shop app index.html
if [ -f "mainapp/shop/index.html" ]; then
    echo -e "${GREEN}  ✓ Updating mainapp/shop/index.html${NC}"
    sed -i 's/app\.js?v=[0-9]*/app.js/g' mainapp/shop/index.html
    sed -i "s|js/app\.js|js/app.js?v=$CACHE_VERSION|g" mainapp/shop/index.html
fi

echo -e "${GREEN}  ✓ Cache version: $CACHE_VERSION${NC}"

# Step 5: Verify required files exist
echo -e "\n${YELLOW}📋 Verifying required files...${NC}"

if [ ! -f "server.js" ]; then
    echo -e "${RED}❌ ERROR: server.js not found!${NC}"
    exit 1
fi

if [ ! -f ".env" ]; then
    echo -e "${RED}❌ ERROR: .env file not found!${NC}"
    exit 1
fi

echo -e "${GREEN}  ✓ All required files present${NC}"

# Step 6: Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    npm install
fi

# Step 7: Start the server with PM2
echo -e "\n${YELLOW}🚀 Starting server with PM2...${NC}"
pm2 start server.js --name padoo-delivery --time

# Step 8: Save PM2 configuration
echo -e "${YELLOW}💾 Saving PM2 configuration...${NC}"
pm2 save

# Step 9: Display server status
echo -e "\n${GREEN}✅ Server started successfully!${NC}"
echo "================================================"
pm2 status

# Step 10: Display useful information
echo -e "\n${YELLOW}📊 Useful Commands:${NC}"
echo "  pm2 logs padoo-delivery    - View logs"
echo "  pm2 restart padoo-delivery - Restart server"
echo "  pm2 stop padoo-delivery    - Stop server"
echo "  pm2 monit                  - Monitor server"

echo -e "\n${GREEN}🎉 Server is ready!${NC}"
echo -e "${YELLOW}⚠️  Remember to hard refresh your browser: Ctrl + Shift + R${NC}"
echo -e "${YELLOW}📌 Cache version: $CACHE_VERSION${NC}"
echo "================================================"

