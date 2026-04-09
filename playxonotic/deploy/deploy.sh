#!/bin/bash
set -e

VPS_HOST="72.61.151.199"
VPS_USER="root"
VPS_DIR="/var/www/playxonotic"

echo "=== Building frontend ==="
cd ../frontend
npm run build
echo "Frontend built."

echo "=== Deploying to VPS ==="

# Upload backend (includes new save model + routes)
echo "Uploading backend..."
rsync -avz --exclude='node_modules' --exclude='.env' ../backend/ ${VPS_USER}@${VPS_HOST}:${VPS_DIR}/backend/

# Upload frontend build
echo "Uploading frontend..."
rsync -avz ../frontend/dist/ ${VPS_USER}@${VPS_HOST}:${VPS_DIR}/frontend/

# Upload proxy
echo "Uploading proxy..."
rsync -avz --exclude='node_modules' --exclude='.env' ../proxy/ ${VPS_USER}@${VPS_HOST}:${VPS_DIR}/proxy/

# Upload nginx config (from deploy dir; cwd is frontend/ after build)
echo "Uploading nginx config..."
rsync -avz ../deploy/nginx.conf ${VPS_USER}@${VPS_HOST}:/etc/nginx/sites-available/playxonotic

# Upload rebuilt game WASM files (if present)
GAME_BUILD="../../xonotic-web-port/source/darkplaces"
if [ -f "${GAME_BUILD}/darkplaces-wasm.html" ]; then
  echo "Uploading rebuilt game WASM files..."
  rsync -avz ${GAME_BUILD}/darkplaces-wasm.html ${GAME_BUILD}/darkplaces-wasm.js ${GAME_BUILD}/darkplaces-wasm.wasm ${VPS_USER}@${VPS_HOST}:${VPS_DIR}/game/
  if [ -f "${GAME_BUILD}/darkplaces-wasm.data" ]; then
    rsync -avz ${GAME_BUILD}/darkplaces-wasm.data ${VPS_USER}@${VPS_HOST}:${VPS_DIR}/game/
  fi
  echo "Game files uploaded."
else
  echo "No rebuilt game files found -- skipping game upload."
  echo "  Build with: cd xonotic-web-port && bash build-wasm.sh"
fi

echo ""
echo "=== Deploy complete ==="
echo ""
echo "SSH into VPS and run:"
echo "  cd ${VPS_DIR}/backend && npm install --production"
echo "  cd ${VPS_DIR}/proxy && npm install --production"
echo "  Create .env files in backend/ and proxy/ (if not already done)"
echo "  ln -sf /etc/nginx/sites-available/playxonotic /etc/nginx/sites-enabled/"
echo "  rm -f /etc/nginx/sites-enabled/default"
echo "  nginx -t && systemctl reload nginx"
echo "  pm2 restart xon-backend xon-proxy || ("
echo "    pm2 start ${VPS_DIR}/backend/src/index.js --name xon-backend"
echo "    pm2 start ${VPS_DIR}/proxy/index.js --name xon-proxy"
echo "  )"
echo "  pm2 save && pm2 startup"
