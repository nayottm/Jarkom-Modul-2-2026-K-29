#!/bin/bash

# UBAH NAMA NODE DI BAWAH INI SESUAI DENGAN NODE YANG SEDANG DIKERJAKAN
echo "nameserver 192.168.122.1" > /etc/resolv.conf
NODE="gamma"

IP_PRAB="10.78.3.2"
IP_TEDD="10.78.3.3"
IP_FORWARDER="192.168.122.1"

echo "=== Konfigurasi Client: $NODE ==="

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

echo "=== Konfigurasi Node $NODE Selesai ==="