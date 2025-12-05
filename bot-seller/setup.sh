#!/bin/bash

# Konfigurasi Folder
WORKDIR="/usr/local/sbin/alpha-vps"
mkdir -p $WORKDIR

# Warna
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}=== [1/3] MEMPERBAIKI ENVIRONMENT PYTHON ===${NC}"

# Hapus library konflik (Fix Ubuntu 20.04)
rm -rf /usr/lib/python3/dist-packages/OpenSSL
rm -rf /usr/lib/python3/dist-packages/pyOpenSSL-*.egg-info

# Install Pip Resmi
apt update && apt install curl python3-pip -y
curl https://bootstrap.pypa.io/pip/3.8/get-pip.py -o get-pip.py
python3 get-pip.py
rm -f get-pip.py

# Install Module Bot
echo -e "${GREEN}=== [2/3] MENGINSTALL MODULE BOT ===${NC}"
pip3 install pyTelegramBotAPI paramiko requests telethon cryptography

# Membuat Service Systemd
echo -e "${GREEN}=== [3/3] MEMBUAT SERVICE SYSTEMD ===${NC}"
cat > /etc/systemd/system/alpha-store.service << END
[Unit]
Description=Alpha Script Store Bot
After=network.target

[Service]
WorkingDirectory=$WORKDIR
ExecStart=/usr/bin/python3 store.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable alpha-store

echo -e "${GREEN}✅ SETUP SELESAI! Silakan lanjutkan membuat file berikutnya.${NC}"
