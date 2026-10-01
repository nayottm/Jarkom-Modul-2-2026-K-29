#!/bin/bash

# 1. Update repository dan install apache2-utils
apt-get update
apt-get install apache2-utils -y

# 2. Buat file kredensial .htpasswd
# Menggunakan tanda kutip pada password untuk mencegah ekspansi karakter wildcard (*) oleh shell
htpasswd -b -c /etc/apache2/.htpasswd prabs "pakar_pinter_jadi_gob***"

# 3. Otomatisasi konfigurasi Basic Auth pada Apache
# Membuat file konfigurasi modular khusus untuk autentikasi /admin
cat << 'EOF' > /etc/apache2/conf-available/admin-auth.conf
<Location /admin>
    AuthType Basic
    AuthName "Restricted Area"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
</Location>
EOF

# Aktifkan konfigurasi yang baru dibuat
a2enconf admin-auth

# 4. Buat direktori dan file index untuk memastikan HTTP 200 (bukan 404 atau 403)
mkdir -p /var/www/html/admin
echo "Ruang rahasia sindikat" > /var/www/html/admin/index.html

# 5. Restart Apache untuk menerapkan semua perubahan
systemctl restart apache2
# atau bisa menggunakan: service apache2 restart

echo "Setup Basic Authentication selesai."