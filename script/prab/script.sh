#!/bin/bash

echo "nameserver 192.168.122.1" > /etc/resolv.conf
NODE="prab"
DOMAIN="K29.com"
IP_PRAB="10.78.3.2"
IP_TEDD="10.78.3.3"
IP_FORWARDER="192.168.122.1"

echo "=== Konfigurasi DNS Master: $NODE ==="

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

# 4. Konfigurasi Forwarder (named.conf.options)
cat > /etc/bind/named.conf.options <<EOF
options {
        directory "/var/cache/bind";
        forwarders {
                $IP_FORWARDER;
        };
        allow-query { any; };
        auth-nxdomain no;
        listen-on-v6 { any; };
};
EOF

# 5. Konfigurasi Zone Local (named.conf.local)
cat > /etc/bind/named.conf.local <<EOF
zone "$DOMAIN" {
        type master;
        notify yes;
        allow-transfer { $IP_TEDD; };
        file "/etc/bind/jarkom/$DOMAIN";
};

zone "2.78.10.in-addr.arpa" {
    type master;
    notify yes;
    allow-transfer { 10.78.3.3; };
    file "/etc/bind/jarkom/2.78.10.in-addr.arpa";
};

zone "3.78.10.in-addr.arpa" {
    type master;
    notify yes;
    allow-transfer { 10.78.3.3; };
    file "/etc/bind/jarkom/3.78.10.in-addr.arpa";
};

zone "4.78.10.in-addr.arpa" {
    type master;
    notify yes;
    allow-transfer { 10.78.3.3; };
    file "/etc/bind/jarkom/4.78.10.in-addr.arpa";
};
EOF

# 6. Pembuatan File Zone dengan Semua IP Entitas (Soal 5)
mkdir -p /etc/bind/jarkom
cat > /etc/bind/jarkom/$DOMAIN <<EOF
\$TTL    604800
@       IN      SOA     prab.$DOMAIN. root.$DOMAIN. (
                        2026092901 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL
;
@       IN      NS      prab.$DOMAIN.
@       IN      NS      tedd.$DOMAIN.
@       IN      A       10.78.4.2
prab    IN      A       10.78.3.2
tedd    IN      A       10.78.3.3
rootkit IN      A       192.168.122.61
alpha   IN      A       10.78.1.2
beta    IN      A       10.78.1.3
gamma   IN      A       10.78.1.4
delta   IN      A       10.78.5.2
epsilon IN      A       10.78.5.3
abbey   IN      A       10.78.2.2
penny   IN      A       10.78.4.2
obladi  IN      A       10.78.3.4
desmond IN      A       10.78.3.5
oblada  IN      A       10.78.3.6
molly   IN      A       10.78.3.7
alpha     IN      TXT     "alpha"
beta      IN      TXT     "beta"
gamma     IN      TXT     "gamma"
delta     IN      TXT     "delta"
epsilon   IN      TXT     "epsilon"
outbound    IN    CNAME    http.badssl.com.

; A Record untuk vault (obladi & desmond)
vault   IN      A       10.78.3.4
vault   IN      A       10.78.3.5

; A Record untuk core (oblada & molly)
core    IN      A       10.78.3.6
core    IN      A       10.78.3.7

; CNAME Record
www     IN      CNAME   penny.K29.com.
static  IN      CNAME   abbey.K29.com.
EOF

cat > /etc/bind/jarkom/2.78.10.in-addr.arpa <<EOF
\$TTL    604800
@       IN      SOA     prab.K29.com. root.K29.com. (
                        2026092901 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL
;
@       IN      NS      prab.K29.com.
@       IN      NS      tedd.K29.com.
2       IN      PTR     abbey.K29.com.
EOF

cat > /etc/bind/jarkom/3.78.10.in-addr.arpa <<EOF
\$TTL    604800
@       IN      SOA     prab.K29.com. root.K29.com. (
                        2026092901 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL
;
@       IN      NS      prab.K29.com.
@       IN      NS      tedd.K29.com.
4       IN      PTR     vault.K29.com.
5       IN      PTR     vault.K29.com.
6       IN      PTR     core.K29.com.
7       IN      PTR     core.K29.com.
EOF

cat > /etc/bind/jarkom/4.78.10.in-addr.arpa <<EOF
\$TTL    604800
@       IN      SOA     prab.K29.com. root.K29.com. (
                        2026092901 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL
;
@       IN      NS      prab.K29.com.
@       IN      NS      tedd.K29.com.
2       IN      PTR     penny.K29.com.
EOF


# 7. Restart Layanan BIND9
service bind9 restart
echo "=== Konfigurasi Node $NODE Selesai ==="
