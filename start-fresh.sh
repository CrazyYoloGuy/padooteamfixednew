#!/bin/bash

# ============================================
# Fresh Start Script for Padoo Delivery
# This ensures clean startup with no cache issues
# ============================================

echo "🚀 Starting Fresh Padoo Delivery Setup..."
echo ""

# Step 1: Kill all existing Node processes
echo "📛 Step 1: Stopping all existing processes..."
pm2 delete all 2>/dev/null || true
pkill -9 node 2>/dev/null || true
sleep 2

# Step 2: Navigate to correct directory
echo "📁 Step 2: Navigating to project directory..."
cd ~/padooteamfixed || { echo "❌ Error: padooteamfixed folder not found!"; exit 1; }
echo "✅ Current directory: $(pwd)"
echo ""

# Step 3: Clear Node.js cache
echo "🧹 Step 3: Clearing Node.js cache..."
rm -rf node_modules/.cache 2>/dev/null || true
npm cache clean --force 2>/dev/null || true
echo "✅ Cache cleared"
echo ""

# Step 4: Add cache-busting version to HTML files
echo "🔄 Step 4: Adding cache-busting to prevent browser cache..."
TIMESTAMP=$(date +%s)

# Update delivery app index.html
if [ -f "mainapp/delivery/index.html" ]; then
    sed -i.bak "s|js/app.js?v=[0-9]*|js/app.js?v=$TIMESTAMP|g" mainapp/delivery/index.html
    sed -i.bak "s|js/app.js\"|js/app.js?v=$TIMESTAMP\"|g" mainapp/delivery/index.html
    echo "✅ Updated mainapp/delivery/index.html with cache buster: v=$TIMESTAMP"
fi

# Update shop app index.html
if [ -f "mainapp/shop/index.html" ]; then
    sed -i.bak "s|js/app.js?v=[0-9]*|js/app.js?v=$TIMESTAMP|g" mainapp/shop/index.html
    sed -i.bak "s|js/app.js\"|js/app.js?v=$TIMESTAMP\"|g" mainapp/shop/index.html
    echo "✅ Updated mainapp/shop/index.html with cache buster: v=$TIMESTAMP"
fi

echo ""

# Step 5: Verify changes are in the files
echo "🔍 Step 5: Verifying code changes..."
if grep -q "Stay on current page" mainapp/delivery/js/app.js; then
    echo "✅ Order redirect fix found in app.js"
else
    echo "⚠️  WARNING: Order redirect fix NOT found in app.js!"
fi

if grep -q "language VARCHAR(5)" mainapp/delivery/database_migrations.sql; then
    echo "✅ Language column migration found"
else
    echo "⚠️  WARNING: Language migration NOT found!"
fi
echo ""

# Step 6: Start the server
echo "🚀 Step 6: Starting server with PM2..."
pm2 start server.js --name padoo-delivery --time
pm2 save
echo ""

# Step 7: Wait for server to start
echo "⏳ Waiting for server to start..."
sleep 3
echo ""

# Step 8: Verify server is running
echo "✅ Step 7: Verifying server status..."
pm2 list
echo ""

# Step 9: Show server info
echo "📊 Server Information:"
pm2 info padoo-delivery | grep -E "status|script path|exec cwd|uptime"
echo ""

# Step 10: Test if server is responding
echo "🧪 Step 8: Testing server response..."
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ Server is responding on port 3000"
else
    echo "⚠️  WARNING: Server not responding on port 3000"
fi
echo ""

# Final instructions
echo "============================================"
echo "✅ SETUP COMPLETE!"
echo "============================================"
echo ""
echo "📝 Next Steps:"
echo "1. Open your browser in INCOGNITO mode"
echo "2. Go to your website"
echo "3. Test the changes:"
echo "   - Accept an order (should stay on Orders page)"
echo "   - Change language to Greek (should persist after refresh)"
echo ""
echo "🔧 Useful Commands:"
echo "   pm2 logs padoo-delivery    - View server logs"
echo "   pm2 restart padoo-delivery - Restart server"
echo "   pm2 stop padoo-delivery    - Stop server"
echo "   ./start-fresh.sh           - Run this script again"
echo ""
echo "Cache buster version: v=$TIMESTAMP"
echo "All browsers will now load fresh files!"
echo "============================================"

