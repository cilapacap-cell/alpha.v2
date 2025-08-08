#!/bin/bash

# ==================================================
#           SISTEM PERIZINAN SCRIPT
# ==================================================
# Definisikan variabel yang dibutuhkan
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Dapatkan IP publik dari VPS yang menjalankan skrip
MYIP=$(curl -sS icanhazip.com)

# URL file yang berisi daftar IP yang diizinkan
data_ip="https://github.com/hokagelegend9999/ijin/raw/refs/heads/main/genom-pro"

# Ambil konten dari file izin
IZIN=$(curl -sS "$data_ip")

# Tampilkan pesan pengecekan
echo "Mengecek Izin Akses Script..."
sleep 2

# Periksa apakah IP VPS saat ini ada di dalam daftar izin
if echo "$IZIN" | grep -q -w "$MYIP"; then
    # Jika IP ditemukan, tampilkan pesan sukses dan lanjutkan skrip
    echo -e "${GREEN}TERIMAKASIH TELAH MENGGUNAKAN SCRIPT ALPHA V2 PRO${NC}"
    sleep 2
    clear
else
    # Jika IP tidak ditemukan, tampilkan pesan error dan hentikan skrip
    echo -e "${RED}maaf hanya untuk pengguna SCRIPT ALPHA PRO${NC}"
    echo "IP VPS Anda: $MYIP tidak terdaftar."
    echo "Silakan hubungi admin untuk mendaftarkan IP Anda."
    exit 0
fi
# ==================================================
#       AKHIR DARI SISTEM PERIZINAN
# ==================================================


# Skrip Asli Anda Dimulai Dari Sini
NS=$( cat /etc/xray/dns )
PUB=$( cat /etc/slowdns/server.pub )
domain=$(cat /etc/xray/domain)
#color
grenbo="\e[92;1m"
NC='\e[0m'
#install
apt update && apt upgrade
apt install python3 python3-pip git -y
cd /usr/bin
wget https://github.com/hokagelegend9999/alpha.v2/raw/refs/heads/main/bot/bot.zip
unzip bot.zip
mv bot/* /usr/bin
chmod +x /usr/bin/*
rm -rf bot.zip
clear
wget https://github.com/hokagelegend9999/alpha.v2/raw/refs/heads/main/bot/kyt.zip
unzip kyt.zip
pip3 install -r kyt/requirements.txt

clear
echo ""
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " \e[1;97;101m          ADD BOT PANEL          \e[0m"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "${grenbo}Tutorial Creat Bot and ID Telegram${NC}"
echo -e "${grenbo}[*] Creat Bot and Token Bot : @BotFather${NC}"
echo -e "${grenbo}[*] Info Id Telegram : @MissRose_bot , perintah /info${NC}"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -e -p "[*] Input your Bot Token : " bottoken
read -e -p "[*] Input Your Id Telegram : " admin
echo -e BOT_TOKEN='"'$bottoken'"' >> /usr/bin/kyt/var.txt
echo -e ADMIN='"'$admin'"' >> /usr/bin/kyt/var.txt
echo -e DOMAIN='"'$domain'"' >> /usr/bin/kyt/var.txt
echo -e PUB='"'$PUB'"' >> /usr/bin/kyt/var.txt
echo -e HOST='"'$NS'"' >> /usr/bin/kyt/var.txt
clear

cat > /etc/systemd/system/kyt.service << END
[Unit]
Description=Simple kyt - @kyt
After=network.target

[Service]
WorkingDirectory=/usr/bin
ExecStart=/usr/bin/python3 -m kyt
Restart=always

[Install]
WantedBy=multi-user.target
END

systemctl start kyt
systemctl enable kyt
systemctl restart kyt
cd /root
rm -f kyt.sh
echo "Done"
echo "Your Data Bot"
echo -e "==============================="
echo "Token Bot         : $bottoken"
echo "Admin          : $admin"
echo "Domain        : $domain"
echo "Pub            : $PUB"
echo "Host           : $NS"
echo -e "==============================="
echo "Setting done"
sleep 2
clear

echo " Installations complete, type /menu on your bot"
