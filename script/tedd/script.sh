#!/bin/bash

echo "nameserver 192.168.122.1" > /etc/resolv.conf
NODE="tedd"
DOMAIN="K29.com"
IP_PRAB="10.78.3.2"
IP_TEDD="10.78.3.3"
IP_FORWARDER="192.168.122.1"

echo "=== Konfigurasi DNS Slave: $NODE ==="

# 1. Konfigurasi Hostname (Soal 5)
echo "$NODE" > /etc/hostname
hostname "$NODE"
sed -i '/127.0.1.1/d' /etc/hosts
echo "127.0.1.1       $NODE" >> /etc/hosts

# 2. Konfigurasi Resolver DNS (Soal 4)
cat > /etc/resolv.conf <<EOF
nameserver $IP_PRAB
nameserver $IP_TEDD
nameserver $IP_FORWARDER
EOF

# 3. Instalasi BIND9
apt-get update
apt-get install bind9 -y
ln -s /etc/init.d/named /etc/init.d/bind9

# 4. Konfigurasi Zone Slave (named.conf.local)
mkdir -p /etc/bind/jarkom
cat > /etc/bind/named.conf.local <<EOF
zone "$DOMAIN" {
        type slave;
        masters { $IP_PRAB; };
        file "/etc/bind/jarkom/$DOMAIN";
};
zone "2.78.10.in-addr.arpa" {
    type slave;
    masters { 10.78.3.2; };
    file "/etc/bind/jarkom/2.78.10.in-addr.arpa";
};

zone "3.78.10.in-addr.arpa" {
    type slave;
    masters { 10.78.3.2; };
    file "/etc/bind/jarkom/3.78.10.in-addr.arpa";
};

zone "4.78.10.in-addr.arpa" {
    type slave;
    masters { 10.78.3.2; };
    file "/etc/bind/jarkom/4.78.10.in-addr.arpa";
};
EOF

# 5. Restart Layanan BIND9
service bind9 restart
echo "=== Konfigurasi Node $NODE Selesai ==="