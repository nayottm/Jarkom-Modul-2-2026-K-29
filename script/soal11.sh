#!/bin/bash

# ==============================================================================
# 1. KONFIGURASI PENNY (APACHE REVERSE PROXY)
# Jalankan seluruh blok ini di terminal node: PENNY
# ==============================================================================
echo "10.78.3.4 obladi" >> /etc/hosts
echo "10.78.3.5 desmond" >> /etc/hosts

apt update && apt install -y apache2
a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers

cat << 'EOF' > /etc/apache2/sites-available/penny.conf
<VirtualHost *:80>
    ServerName penny.local
    
    ProxyPreserveHost On
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"
    
    <Proxy balancer://penny_cluster>
        BalancerMember http://obladi:80
        BalancerMember http://desmond:80
        ProxySet lbmethod=byrequests
    </Proxy>
    
    ProxyPass / balancer://penny_cluster/
    ProxyPassReverse / balancer://penny_cluster/
</VirtualHost>
EOF

a2ensite penny
service apache2 restart


# ==============================================================================
# 2. KONFIGURASI ABBEY (NGINX REVERSE PROXY)
# Jalankan seluruh blok ini di terminal node: ABBEY
# ==============================================================================
echo "10.78.3.6 oblada" >> /etc/hosts
echo "10.78.3.7 molly" >> /etc/hosts

service apache2 stop 2>/dev/null
apt purge -y apache2 apache2-utils apache2-bin 2>/dev/null
apt autoremove -y

apt update && apt install -y nginx
rm -f /etc/nginx/sites-enabled/default

cat << 'EOF' > /etc/nginx/sites-available/abbey
upstream abbey_cluster {
    server oblada:80;
    server molly:80;
}

server {
    listen 80;
    server_name abbey.local;

    location / {
        proxy_pass http://abbey_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

ln -s /etc/nginx/sites-available/abbey /etc/nginx/sites-enabled/
service nginx restart


# ==============================================================================
# 3. KONFIGURASI OBLADI & DESMOND (APACHE BACKEND)
# Jalankan blok ini di terminal node: OBLADI dan DESMOND
# ==============================================================================
apt update && apt install -y apache2 php libapache2-mod-php
rm -f /var/www/html/index.html

cat << 'EOF' > /var/www/html/index.php
<?php
header("Content-Type: text/plain");
echo "Server Backend : " . gethostname() . "\n";
echo "Header Host  : " . (isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : 'Tidak ada') . "\n";
echo "X-Real-IP    : " . (isset($_SERVER['HTTP_X_REAL_IP']) ? $_SERVER['HTTP_X_REAL_IP'] : 'Tidak ada') . "\n";
?>
EOF

service apache2 restart


# ==============================================================================
# 4. KONFIGURASI OBLADA & MOLLY (NGINX BACKEND)
# Jalankan blok ini di terminal node: OBLADA dan MOLLY
# ==============================================================================
service apache2 stop 2>/dev/null
killall -9 apache2 2>/dev/null
apt purge -y apache2 apache2-bin apache2-data apache2-utils 2>/dev/null
apt autoremove -y

apt update && apt install -y nginx

cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    location / {
        default_type text/plain;
        return 200 "Server Backend : $hostname\nHeader Host  : $http_host\nX-Real-IP    : $http_x_real_ip\n";
    }
}
EOF

service nginx restart


# ==============================================================================
# 5. VALIDASI AKHIR (PENGUJIAN KLIEN)
# Jalankan perintah ini di terminal node klien: ALPHA atau BETA
# ==============================================================================
# Uji jalur Penny (Apache):
curl -H "Host: penny.local" http://10.78.4.2/
curl -H "Host: penny.local" http://10.78.4.2/

# Uji jalur Abbey (Nginx):
curl -H "Host: abbey.local" http://10.78.2.2/
curl -H "Host: abbey.local" http://10.78.2.2/