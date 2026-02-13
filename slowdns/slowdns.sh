#!/bin/bash
# =========================================
# Quick Setup | SlowDNS Manager (Auto-Mode)
# =========================================
BGreen='\e[1;32m'
NC='\e[0m'

# Setting IPtables
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
netfilter-persistent save
netfilter-persistent reload

cd
rm -rf /root/nsdomain
rm -f /root/nsdomain

# =================================================================
# [PERBAIKAN] LOGIKA AUTO-INPUT DARI BOT
# =================================================================
if [[ -n "$AUTO_NS" ]]; then
    # Jika variabel dikirim dari Bot, gunakan otomatis
    SUB_DOMAIN="${AUTO_NS}"
    echo -e "${BGreen} [BOT MODE] Menggunakan NS: $SUB_DOMAIN ${NC}"
else
    # Jika dijalankan manual di terminal
    read -rp "Masukkan Subdomain Yang Dipakai Host Sekarang: " -e sub
    SUB_DOMAIN=${sub}
fi

NS_DOMAIN=${SUB_DOMAIN}
echo "$NS_DOMAIN" > /root/nsdomain
# =================================================================

nameserver=$(cat /root/nsdomain)
domen=$(cat /etc/xray/domain)

# Install Dependencies
apt update -y
apt install -y python3 python3-dnslib net-tools ncurses-utils dnsutils git curl wget screen cron iptables dos2unix

# Konfigurasi Binary SlowDNS
rm -rf /etc/slowdns
mkdir -m 777 /etc/slowdns
wget -q -O /etc/slowdns/server.key "https://raw.githubusercontent.com/hokagelegend9999/alpha.v2/refs/heads/main/slowdns/server.key"
wget -q -O /etc/slowdns/server.pub "https://raw.githubusercontent.com/hokagelegend9999/alpha.v2/refs/heads/main/slowdns/server.pub"
wget -q -O /etc/slowdns/sldns-server "https://raw.githubusercontent.com/hokagelegend9999/alpha.v2/refs/heads/main/slowdns/sldns-server"
wget -q -O /etc/slowdns/sldns-client "https://raw.githubusercontent.com/hokagelegend9999/alpha.v2/refs/heads/main/slowdns/sldns-client"
chmod +x /etc/slowdns/*

# Install Systemd Service
cat > /etc/systemd/system/client-sldns.service << END
[Unit]
Description=Client SlowDNS By Hokage Legend
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
ExecStart=/etc/slowdns/sldns-client -udp 8.8.8.8:53 --pubkey-file /etc/slowdns/server.pub $nameserver 127.0.0.1:2222
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

cat > /etc/systemd/system/server-sldns.service << END
[Unit]
Description=Server SlowDNS By Hokage Legend
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
ExecStart=/etc/slowdns/sldns-server -udp :5300 -privkey-file /etc/slowdns/server.key $nameserver 127.0.0.1:2269
Restart=always
RestartSec=3s

[Install]
WantedBy=multi-user.target
END

# Enable & Start
systemctl daemon-reload
systemctl enable --now client-sldns server-sldns
systemctl restart client-sldns server-sldns

echo -e "\e[1;32m Success.. \e[0m"
sleep 2
