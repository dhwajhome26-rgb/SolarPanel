#!/usr/bin/env bash

clear
echo "================================="
echo "        🌞 SOLAR PANEL"
echo "================================="
echo ""
echo "( 1 ) Install Solar Panel (Solar + Blueprint + Nebula)"
echo "( 2 ) Install Solar Wings (Node)"
echo ""
read -p "[ Select Number ]: " choice

# ===============================
# OPTION 1 - PANEL INSTALL
# ===============================
if [ "$choice" == "1" ]; then

  read -p "Enter Domain (panel.example.com): " DOMAIN
  read -p "Enter MySQL Root Password: " DBPASS

  echo "Updating system..."
  apt update -y && apt upgrade -y

  echo "Installing dependencies..."
  apt install -y curl wget git unzip tar nginx redis-server mysql-server software-properties-common

  add-apt-repository ppa:ondrej/php -y
  apt update -y

  apt install -y php8.1 php8.1-cli php8.1-gd php8.1-mysql php8.1-pdo php8.1-mbstring php8.1-tokenizer php8.1-bcmath php8.1-xml php8.1-fpm

  echo "Creating database..."
  mysql -u root -p$DBPASS -e "CREATE DATABASE solarpanel;"
  mysql -u root -p$DBPASS -e "CREATE USER 'solar'@'127.0.0.1' IDENTIFIED BY '$DBPASS';"
  mysql -u root -p$DBPASS -e "GRANT ALL PRIVILEGES ON solarpanel.* TO 'solar'@'127.0.0.1';"
  mysql -u root -p$DBPASS -e "FLUSH PRIVILEGES;"

  echo "Downloading Pterodactyl Panel..."
  mkdir -p /var/www/solarpanel
  cd /var/www/solarpanel

  curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
  tar -xzvf panel.tar.gz
  chmod -R 755 storage/* bootstrap/cache/

  echo "Installing Composer..."
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer

  composer install --no-dev --optimize-autoloader

  cp .env.example .env
  php artisan key:generate

  echo "Configuring environment..."
  sed -i "s/DB_DATABASE=.*/DB_DATABASE=solarpanel/" .env
  sed -i "s/DB_USERNAME=.*/DB_USERNAME=solar/" .env
  sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DBPASS/" .env
  sed -i "s|APP_URL=.*|APP_URL=http://$DOMAIN|" .env

  php artisan migrate --seed --force

  echo "Installing Blueprint..."
  curl -s https://raw.githubusercontent.com/BlueprintFramework/framework/main/install.sh | bash

  echo "Installing Nebula Theme..."
  blueprint -install nebula

  echo "Setting permissions..."
  chown -R www-data:www-data /var/www/solarpanel

  echo "Configuring Nginx..."
  cat > /etc/nginx/sites-available/solarpanel <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    root /var/www/solarpanel/public;

    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }
}
EOF

  ln -s /etc/nginx/sites-available/solarpanel /etc/nginx/sites-enabled/
  nginx -t && systemctl restart nginx

  echo ""
  echo "================================="
  echo "✅ SolarPanel Installed Successfully!"
  echo "Open: http://$DOMAIN"
  echo "================================="

# ===============================
# OPTION 2 - WINGS INSTALL
# ===============================
elif [ "$choice" == "2" ]; then

  echo "Installing Docker..."
  curl -fsSL https://get.docker.com | sh

  echo "Downloading Wings..."
  mkdir -p /etc/pterodactyl
  curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
  chmod +x /usr/local/bin/wings

  echo ""
  echo "Wings Installed."
  echo "Go to SolarPanel → Create Node → Copy config.yml"
  echo "Paste into: /etc/pterodactyl/config.yml"
  echo "Then run: wings --debug"

else
  echo "Invalid option!"
fi
