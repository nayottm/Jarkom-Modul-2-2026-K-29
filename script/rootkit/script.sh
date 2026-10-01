#!/bin/bash
NAME="rootkit"
IP="10.78.1.1"
DOMAIN="K29.com"

hostname "$NAME"
echo "$NAME" > /etc/hostname
sed -i "/$NAME\.$DOMAIN/d" /etc/hosts
echo "$IP $NAME.$DOMAIN $NAME" >> /etc/hosts

echo "[+] hostname : $(hostname)"
echo "[+] FQDN     : $(hostname -f)"
