#!/bin/bash
# Simpan sebagai: install-udp.sh

clear
echo "=========================================="
echo "    INSTALLER UDP CUSTOM (DEFAULT)        "
echo "=========================================="

# 1. Hapus & Buat Folder
rm -rf /etc/udp
mkdir -p /etc/udp
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# 2. Download Binary UDP Custom
cd /etc/udp
wget -q -O udp-custom "https://github.com/hokagelegend9999/alpha.v2/raw/refs/heads/main/udp-custom/udp-custom-linux-amd64"
chmod +x udp-custom

# 3. Buat Config JSON
cat <<EOF > /etc/udp/config.json
{
  "listen": ":36712",
  "stream_buffer": 33554432,
  "receive_buffer": 83886080,
  "auth": {
    "mode": "passwords"
  }
}
EOF
chmod 644 /etc/udp/config.json

# 4. Buat Service (Default Exclude: 22=SSH, 53=DNS, 68=DHCP)
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team

[Service]
User=root
Type=simple
ExecStart=/etc/udp/udp-custom server -exclude 22,53,68
WorkingDirectory=/etc/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF

# 5. Start Service
systemctl daemon-reload
systemctl enable udp-custom &>/dev/null
systemctl start udp-custom &>/dev/null
systemctl restart udp-custom &>/dev/null

echo -e "\n[OK] UDP Custom Terinstall."
echo -e "Port Exclude Default: 22, 53, 68"
