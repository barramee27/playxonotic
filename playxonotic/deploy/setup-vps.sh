#!/bin/bash
set -e

echo "=== PlayXonotic VPS Setup ==="
echo "Ubuntu 22.04 LTS"

# Update system
apt update && apt upgrade -y

# Install essentials
apt install -y nginx certbot python3-certbot-nginx ufw curl git build-essential

# Install Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Install PM2 for process management
npm install -g pm2

# Firewall
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw allow 26000/udp  # Xonotic game server
ufw allow 27960/tcp  # WebSocket proxy (internal, nginx proxies to it)
ufw --force enable

# Create app directories
mkdir -p /var/www/playxonotic/{frontend,game,backend,proxy}
mkdir -p /opt/xonotic-server

echo "=== VPS base setup complete ==="
echo ""
echo "Next steps:"
echo "1. Upload files to /var/www/playxonotic/"
echo "2. Copy nginx config to /etc/nginx/sites-available/playxonotic"
echo "3. Run: ln -s /etc/nginx/sites-available/playxonotic /etc/nginx/sites-enabled/"
echo "4. Run: rm /etc/nginx/sites-enabled/default"
echo "5. Run: nginx -t && systemctl reload nginx"
echo "6. Run: certbot --nginx -d playxonotic.com -d www.playxonotic.com"
echo "7. Start services with PM2"
