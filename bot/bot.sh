#!/bin/bash

# ==================================================
#           SISTEM PERIZINAN SCRIPT
# ==================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

MYIP=$(curl -sS icanhazip.com)
data_ip="https://github.com/hokagelegend9999/ijin/raw/refs/heads/main/genom-pro"
IZIN=$(curl -sS "$data_ip")

echo "Mengecek Izin Akses Script..."
sleep 2
if echo "$IZIN" | grep -q -w "$MYIP"; then
    echo -e "${GREEN}TERIMAKASIH TELAH MENGGUNAKAN SCRIPT ALPHA V2 PRO${NC}"
    sleep 2
    clear
else
    echo -e "${RED}maaf hanya untuk pengguna SCRIPT ALPHA PRO${NC}"
    echo "IP VPS Anda: $MYIP tidak terdaftar."
    exit 1
fi

# ==================================================
#             PROSES INSTALASI
# ==================================================

# --- Cek dan Buat File Konfigurasi Jika Tidak Ada ---
mkdir -p /etc/xray
mkdir -p /etc/slowdns
files_to_check=("/etc/xray/dns" "/etc/slowdns/server.pub" "/etc/xray/domain")
warning_message=""
for file_path in "${files_to_check[@]}"; do
    if [ ! -f "$file_path" ]; then
        touch "$file_path"
        warning_message="${warning_message}\n- $file_path (kosong, perlu diisi manual)"
    fi
done
if [ ! -z "$warning_message" ]; then
    echo -e "\n${RED}================ PERHATIAN PENTING =================${NC}"
    echo -e "${YELLOW}Beberapa file konfigurasi penting tidak ada dan telah dibuat kosong."
    echo -e "Anda HARUS mengedit file-file ini secara manual agar bot berfungsi:${NC}"
    echo -e "${YELLOW}$warning_message${NC}"
    echo -e "${RED}=====================================================${NC}"
    read -n 1 -s -r -p "Tekan tombol apa saja untuk melanjutkan instalasi..."
    echo
fi

NS=$(cat /etc/xray/dns)
PUB=$(cat /etc/slowdns/server.pub)
domain=$(cat /etc/xray/domain)
grenbo="\e[92;1m"

echo "Memulai instalasi paket yang dibutuhkan..."
apt-get update -y > /dev/null 2>&1
apt-get install -y python3 python3-pip git unzip wget > /dev/null 2>&1
echo "Instalasi paket selesai."

echo "Mengunduh dan menyiapkan file bot..."
cd /usr/bin || exit
rm -rf bot.zip kyt.zip bot kyt
wget -q https://github.com/hokagelegend9999/alpha.v2/raw/refs/heads/main/bot/bot.zip
unzip -o bot.zip > /dev/null 2>&1
mv bot/* /usr/bin/
chmod +x /usr/bin/*
rm -rf bot.zip bot
wget -q https://github.com/hokagelegend9999/alpha.v2/raw/refs/heads/main/bot/kyt.zip
unzip -o kyt.zip > /dev/null 2>&1
pip3 install -r kyt/requirements.txt > /dev/null 2>&1
echo "Penyiapan file bot selesai."
clear

# --- Input Konfigurasi Bot ---
echo ""
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " \e[1;97;101m          ADD BOT PANEL          \e[0m"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -e -p "[*] Input your Bot Token : " bottoken
read -e -p "[*] Input Your Id Telegram : " admin

rm -f /usr/bin/kyt/var.txt
echo -e BOT_TOKEN='"'$bottoken'"' >> /usr/bin/kyt/var.txt
echo -e ADMIN='"'$admin'"' >> /usr/bin/kyt/var.txt
echo -e DOMAIN='"'$domain'"' >> /usr/bin/kyt/var.txt
echo -e PUB='"'$PUB'"' >> /usr/bin/kyt/var.txt
echo -e HOST='"'$NS'"' >> /usr/bin/kyt/var.txt
clear

echo "Membuat dan mengaktifkan layanan bot..."
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
systemctl enable kyt > /dev/null 2>&1
systemctl restart kyt

# ==================================================
#    MEMBUAT SKRIP MENU MANAJEMEN
# ==================================================
cat > /usr/local/bin/menu-bot << 'EOF'
#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

check_status() {
    if systemctl is-active --quiet kyt; then
        echo -e "${GREEN}AKTIF${NC}"
    else
        echo -e "${RED}TIDAK AKTIF${NC}"
    fi
}

edit_config() {
    echo "Konfigurasi saat ini:"
    source /usr/bin/kyt/var.txt
    echo "Token: $BOT_TOKEN"
    echo "Admin: $ADMIN"
    echo ""
    read -e -p "Masukkan Bot Token baru (kosongkan jika tidak ingin ganti): " new_bottoken
    read -e -p "Masukkan ID Telegram Admin baru (kosongkan jika tidak ingin ganti): " new_admin

    if [ -n "$new_bottoken" ]; then
        sed -i "s/BOT_TOKEN=\".*\"/BOT_TOKEN=\"$new_bottoken\"/" /usr/bin/kyt/var.txt
    fi

    if [ -n "$new_admin" ]; then
        sed -i "s/ADMIN=\".*\"/ADMIN=\"$new_admin\"/" /usr/bin/kyt/var.txt
    fi

    echo "Konfigurasi diperbarui. Merestart bot..."
    systemctl restart kyt
    sleep 2
}

while true; do
    clear
    source /usr/bin/kyt/var.txt
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e " \e[1;97;101m          KELOLA BOT TELEGRAM          \e[0m"
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "Status Bot: $(check_status)"
    echo -e "Token      : ${BOT_TOKEN}"
    echo -e "Admin ID   : ${ADMIN}"
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e " [1] Cek Log Bot"
    echo -e " [2] Restart Bot"
    echo -e " [3] Edit Token / ID Admin"
    echo -e " [x] Keluar"
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -p "Pilih opsi: " opt

    case $opt in
        1)
            journalctl -u kyt -f --no-pager
            ;;
        2)
            systemctl restart kyt
            echo "Bot direstart."
            sleep 1
            ;;
        3)
            edit_config
            ;;
        x|X)
            exit 0
            ;;
        *)
            echo -e "${RED}Opsi tidak valid!${NC}"
            sleep 1
            ;;
    esac
done
EOF

chmod +x /usr/local/sbin/menu-bot

# --- PESAN TERAKHIR ---
clear
echo -e "${GREEN}===============================================${NC}"
echo -e "         INSTALASI BOT SELESAI"
echo -e "${GREEN}===============================================${NC}"
echo -e "Bot Telegram Anda sekarang sudah aktif."
echo -e "Untuk mengelola bot di kemudian hari, Anda tidak"
echo -e "perlu menjalankan installer ini lagi."
echo ""
echo -e "Cukup ketik perintah di bawah ini di terminal:"
echo -e "${YELLOW}menu-bot${NC}"
echo ""
