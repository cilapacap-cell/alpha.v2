#!/bin/bash

# ==================================================
#           SISTEM PERIZINAN SCRIPT
# ==================================================
# Definisikan variabel yang dibutuhkan
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
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

#install
apt update && apt upgrade
apt install python3 python3-pip git -y
cd /usr/bin
wget -q https://github.com/hokagelegend9999/alpha.v2/raw/refs/heads/main/bot/bot.zip
unzip -o bot.zip
mv bot/* /usr/bin
chmod +x /usr/bin/*
rm -rf bot.zip
clear
wget -q https://github.com/hokagelegend9999/alpha.v2/raw/refs/heads/main/bot/kyt.zip
unzip -o kyt.zip
pip3 install -r kyt/requirements.txt > /dev/null 2>&1

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

# Hapus file var.txt lama jika ada untuk menghindari duplikasi
rm -f /usr/bin/kyt/var.txt

# Buat file var.txt baru
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

systemctl daemon-reload
systemctl start kyt
systemctl enable kyt
systemctl restart kyt
cd /root
rm -f kyt.sh

# ==================================================
#           MENU MANAJEMEN BOT
# ==================================================

# Fungsi untuk memeriksa status bot
check_status() {
    if systemctl is-active --quiet kyt; then
        echo -e "${GREEN}AKTIF${NC}"
    else
        echo -e "${RED}TIDAK AKTIF${NC}"
    fi
}

# Loop menu utama
while true; do
    clear
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e " \e[1;97;101m          KELOLA BOT TELEGRAM          \e[0m"
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "Status Bot: $(check_status)"
    echo ""
    echo -e "Data Bot Anda:"
    echo -e "  - Token Bot: $bottoken"
    echo -e "  - Admin ID : $admin"
    echo -e "  - Domain   : $domain"
    echo ""
    echo -e "Ketik /menu di bot Telegram Anda untuk memulai."
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e " [1] Cek Log Bot"
    echo -e " [2] Restart Bot"
    echo -e " [x] Keluar"
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -p "Pilih opsi [1-2 atau x]: " opt

    case $opt in
        1)
            echo ""
            echo "Menampilkan log bot... Tekan CTRL+C untuk kembali ke menu."
            sleep 2
            journalctl -u kyt -f --no-pager
            read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali ke menu..."
            ;;
        2)
            echo ""
            echo "Merestart bot..."
            systemctl restart kyt
            sleep 2
            echo "Bot telah direstart."
            sleep 1
            ;;
        x)
            clear
            echo "Terima kasih telah menggunakan skrip ini."
            break
            ;;
        *)
            echo -e "${RED}Opsi tidak valid!${NC}"
            sleep 1
            ;;
    esac
done
