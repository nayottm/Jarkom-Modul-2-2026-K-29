# Dokumentasi Command Modul 2

## Soal 1, 2, 3

### rootkit

```bash
# Jalur Internet (menuju NAT1)
auto eth0
iface eth0 inet dhcp
    up sysctl -w net.ipv4.ip_forward=1
    up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

auto eth1
iface eth1 inet static
    address 10.78.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.78.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 10.78.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 10.78.4.1
    netmask 255.255.255.0

auto eth5
iface eth5 inet static
    address 10.78.5.1
    netmask 255.255.255.0
```

### Subnet 1

**alpha**
```bash
auto eth0
iface eth0 inet static
    address 10.78.1.2
    netmask 255.255.255.0
    gateway 10.78.1.1
```

**beta**
```bash
auto eth0
iface eth0 inet static
    address 10.78.1.3
    netmask 255.255.255.0
    gateway 10.78.1.1
```

**gamma**
```bash
auto eth0
iface eth0 inet static
    address 10.78.1.4
    netmask 255.255.255.0
    gateway 10.78.1.1
```

### Subnet 2

**abbey**
```bash
auto eth0
iface eth0 inet static
    address 10.78.2.2
    netmask 255.255.255.0
    gateway 10.78.2.1
```

### Subnet 3

**prab**
```bash
auto eth0
iface eth0 inet static
    address 10.78.3.2
    netmask 255.255.255.0
    gateway 10.78.3.1
```

**tedd**
```bash
auto eth0
iface eth0 inet static
    address 10.78.3.3
    netmask 255.255.255.0
    gateway 10.78.3.1
```

**obladi**
```bash
auto eth0
iface eth0 inet static
    address 10.78.3.4
    netmask 255.255.255.0
    gateway 10.78.3.1
```

**desmond**
```bash
auto eth0
iface eth0 inet static
    address 10.78.3.5
    netmask 255.255.255.0
    gateway 10.78.3.1
```

**oblada**
```bash
auto eth0
iface eth0 inet static
    address 10.78.3.6
    netmask 255.255.255.0
    gateway 10.78.3.1
```

**molly**
```bash
auto eth0
iface eth0 inet static
    address 10.78.3.7
    netmask 255.255.255.0
    gateway 10.78.3.1
```

### Subnet 4

**penny**
```bash
auto eth0
iface eth0 inet static
    address 10.78.4.2
    netmask 255.255.255.0
    gateway 10.78.4.1
```

### Subnet 5

**delta**
```bash
auto eth0
iface eth0 inet static
    address 10.78.5.2
    netmask 255.255.255.0
    gateway 10.78.5.1
```

**epsilon**
```bash
auto eth0
iface eth0 inet static
    address 10.78.5.3
    netmask 255.255.255.0
    gateway 10.78.5.1
```

### Command semua node

```bash
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

---

## Soal 4

### Instalasi Bind9 (prab)

```bash
apt-get update
apt-get install bind9 -y
ln -s /etc/init.d/named /etc/init.d/bind9
```

### Membuat domain (prab)

```bash
nano /etc/bind/named.conf.local
```

Isi:
```
zone " K29.com" {
    type master;
    notify yes;
    allow-transfer { 10.78.3.3; };
    file "/etc/bind/jarkom/K29.com";
};
```

```bash
mkdir /etc/bind/jarkom
nano /etc/bind/zone.template
```

Isi:
```
$TTL 604800
@   IN  SOA prab.K29.com. root.K29.com. (
        2026092901  ; Serial
        604800      ; Refresh
        86400       ; Retry
        2419200     ; Expire
        604800 )    ; Negative Cache TTL
;
@       IN  NS  prab.K29.com.
@       IN  NS  tedd.K29.com.
@       IN  A   10.78.4.2
prab    IN  A   10.78.3.2
tedd    IN  A   10.78.3.3
```

```bash
cp /etc/bind/zone.template /etc/bind/jarkom/K29.com
nano /etc/bind/jarkom/K29.com
```

### Konfigurasi options (prab)

```bash
nano /etc/bind/named.conf.options
```

Isi:
```
options {
    directory "/var/cache/bind";
    forwarders {
        192.168.122.1;
    };
    allow-query { any; };
    auth-nxdomain no;
    listen-on-v6 { any; };
};
```

### Restart service

```bash
service bind9 restart
named -g   # Atau bisa gunakan ini untuk restart sekaligus debugging
```

### Testing di penjaga directory

```bash
ping K29.com -c 5
```

### Instalasi Bind9 (tedd)

```bash
apt-get update
apt-get install bind9 -y
ln -s /etc/init.d/named /etc/init.d/bind9
mkdir -p /etc/bind/jarkom
nano /etc/bind/named.conf.local
```

Isi:
```
zone "<xxxx>.com" {
    type slave;
    masters { 10.78.3.2; };
    file "/etc/bind/jarkom/K29.com";
};
```

Restart service:
```bash
service bind9 restart
named -g   # Atau bisa gunakan ini untuk restart sekaligus debugging
```

### Client (alpha, beta, gamma, delta, epsilon)

```bash
nano /etc/resolv.conf
```

Isi:
```
nameserver 10.78.3.2
nameserver 10.78.3.3
nameserver 192.168.122.1
```

Testing di client:
```bash
ping K29.com -c 5
```

---

## Soal 5

Di **prab**:

```bash
nano /etc/bind/jarkom/K29.com
```

Tambahkan:
```
rootkit  IN  A  192.168.122.61
alpha    IN  A  10.78.1.2
beta     IN  A  10.78.1.3
gamma    IN  A  10.78.1.4
delta    IN  A  10.78.5.2
epsilon  IN  A  10.78.5.3
abbey    IN  A  10.78.2.2
penny    IN  A  10.78.4.2
obladi   IN  A  10.78.3.4
desmond  IN  A  10.78.3.5
oblada   IN  A  10.78.3.6
molly    IN  A  10.78.3.7
```

Restart service:
```bash
service bind9 restart
named -g   # Atau bisa gunakan ini untuk restart sekaligus debugging
```

Testing:
```bash
ping rootkit.K29.com -c 3
ping abbey.K29.com -c 3
ping molly.K29.com -c 3
```

---

## Soal 6

Cek apakah master dan slave memiliki serial SOA yang sama.

Di **prab**:
```bash
host -t SOA K29.com 10.78.3.2
```

Di **tedd**:
```bash
host -t SOA K29.com 10.78.3.2
```

---

## Soal 7

Di **prab**:

```bash
nano /etc/bind/jarkom/K29.com
```

Tambahkan:
```
; A Record untuk vault (obladi & desmond)
vault   IN  A      10.78.3.4
vault   IN  A      10.78.3.5

; A Record untuk core (oblada & molly)
core    IN  A      10.78.3.6
core    IN  A      10.78.3.7

; CNAME Record
www     IN  CNAME  penny.K29.com.
static  IN  CNAME  abbey.K29.com.
```

Edit serialnya, lalu restart:
```bash
service bind9 restart
```

Testing di client:
```bash
host -t A vault.K29.com
host -t A core.K29.com
host -t CNAME www.K29.com
host -t CNAME static.K29.com
ping www.K29.com -c 2
ping static.K29.com -c 2
```

---

## Soal 8

### Di prab

```bash
nano /etc/bind/named.conf.local
```

Tambahkan:
```
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
```

**2.78.10.in-addr.arpa**
```bash
nano /etc/bind/jarkom/2.78.10.in-addr.arpa
```
```
$TTL 604800
@   IN  SOA prab.K29.com. root.K29.com. (
        2026092901  ; Serial
        604800      ; Refresh
        86400       ; Retry
        2419200     ; Expire
        604800 )    ; Negative Cache TTL
;
@   IN  NS   prab.K29.com.
@   IN  NS   tedd.K29.com.
2   IN  PTR  abbey.K29.com.
```

**3.78.10.in-addr.arpa**
```bash
nano /etc/bind/jarkom/3.78.10.in-addr.arpa
```
```
$TTL 604800
@   IN  SOA prab.K29.com. root.K29.com. (
        2026092901  ; Serial
        604800      ; Refresh
        86400       ; Retry
        2419200     ; Expire
        604800 )    ; Negative Cache TTL
;
@   IN  NS   prab.K29.com.
@   IN  NS   tedd.K29.com.
4   IN  PTR  vault.K29.com.
5   IN  PTR  vault.K29.com.
6   IN  PTR  core.K29.com.
7   IN  PTR  core.K29.com.
```

**4.78.10.in-addr.arpa**
```bash
nano /etc/bind/jarkom/4.78.10.in-addr.arpa
```
```
$TTL 604800
@   IN  SOA prab.K29.com. root.K29.com. (
        2026092901  ; Serial
        604800      ; Refresh
        86400       ; Retry
        2419200     ; Expire
        604800 )    ; Negative Cache TTL
;
@   IN  NS   prab.K29.com.
@   IN  NS   tedd.K29.com.
2   IN  PTR  penny.K29.com.
```

### Di tedd

```bash
nano /etc/bind/named.conf.local
```

Isi:
```
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
```

Restart:
```bash
service bind9 restart
```

### Cek di klien

```bash
host -t PTR 10.78.2.2
host -t PTR 10.78.4.2
host -t PTR 10.78.3.4
host -t PTR 10.78.3.6
host -t PTR 10.78.3.4 10.78.3.2
host -t PTR 10.78.3.4 10.78.3.3
```

---

## Soal 17

_(kosong di dokumen asli)_