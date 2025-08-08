#!/bin/bash

# ==================================================
# BAGIAN 1: PEMBERSIHAN TOTAL BOT LAMA
# ==================================================
echo "=================================================="
echo "      MEMBERSIHKAN INSTALASI BOT LAMA..."
echo "=================================================="
sleep 2

# Hentikan dan nonaktifkan layanan systemd
sudo systemctl stop kyt &> /dev/null
sudo systemctl disable kyt &> /dev/null

# Hapus file layanan
sudo rm -f /etc/systemd/system/kyt.service
sudo systemctl daemon-reload

# Hapus file-file skrip, konfigurasi, dan menu
sudo rm -rf /usr/bin/kyt
sudo rm -f /usr/local/sbin/menu-bot
sudo rm -f /usr/bin/*.session

echo "Pembersihan instalasi lama SELESAI."
echo "=================================================="
sleep 3; clear

# ==================================================
# BAGIAN 2: INSTALASI BOT BARU (DENGAN PERBAIKAN)
# ==================================================
echo "=================================================="
echo "        MEMULAI INSTALASI BOT BARU..."
echo "=================================================="
sleep 2

# --- Perizinan ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
MYIP=$(curl -sS icanhazip.com)
data_ip="https://github.com/hokagelegend9999/ijin/raw/refs/heads/main/genom-pro"
IZIN=$(curl -sS "$data_ip")

echo "Mengecek Izin Akses Script..."
sleep 1
if echo "$IZIN" | grep -q -w "$MYIP"; then
    echo -e "${GREEN}Akses Diterima. Melanjutkan instalasi...${NC}"
    sleep 2; clear
else
    echo -e "${RED}Akses Ditolak. IP VPS Anda ($MYIP) tidak terdaftar.${NC}"
    exit 1
fi

# --- Instalasi ---
# (Bagian instalasi paket dan download file tetap sama)
mkdir -p /etc/xray /etc/slowdns
touch /etc/xray/dns /etc/slowdns/server.pub /etc/xray/domain
NS=$(cat /etc/xray/dns); PUB=$(cat /etc/slowdns/server.pub); domain=$(cat /etc/xray/domain)
apt-get update -y > /dev/null 2>&1
apt-get install -y python3 python3-pip git unzip wget > /dev/null 2>&1
cd /usr/bin || exit
wget -q -O bot.zip https://github.com/hokagelegend9999/alpha.v2/raw/refs/heads/main/bot/bot.zip && unzip -o bot.zip && rm -f bot.zip
wget -q -O kyt.zip https://github.com/hokagelegend9999/alpha.v2/raw/refs/heads/main/bot/kyt.zip && unzip -o kyt.zip && rm -f kyt.zip
mv bot/* /usr/bin/; chmod +x /usr/bin/*; pip3 install -r kyt/requirements.txt > /dev/null 2>&1; rm -rf bot
clear

# --- Input Konfigurasi Bot ---
echo -e "\e[1;97;101m         KONFIGURASI BOT TELEGRAM         \e[0m\n"
read -e -p "[*] Masukkan Bot Token Anda: " bottoken
read -e -p "[*] Masukkan ID Admin Telegram Anda: " admin

mkdir -p /usr/bin/kyt; rm -f /usr/bin/kyt/var.txt
{
    echo "BOT_TOKEN=\"$bottoken\""
    echo "ADMIN=\"$admin\""
    echo "DOMAIN=\"$domain\""
    echo "PUB=\"$PUB\""
    echo "HOST=\"$NS\""
} >> /usr/bin/kyt/var.txt
clear

# --- Membuat Layanan & Menu ---
echo "Membuat layanan systemd dan menu..."
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
systemctl daemon-reload; systemctl enable kyt > /dev/null 2>&1; systemctl restart kyt

cat > /usr/local/sbin/menu-bot << 'EOF'
#!/bin/bash
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
check_status(){ if systemctl is-active --quiet kyt; then echo -e "${GREEN}AKTIF${NC}"; else echo -e "${RED}TIDAK AKTIF${NC}"; fi }
while true; do
    clear
    MYIP=$(curl -sS icanhazip.com)
    data_ip="https://github.com/hokagelegend9999/ijin/raw/refs/heads/main/genom-pro"
    IZIN=$(curl -sS "$data_ip")
    
    # === PERBAIKAN LOGIKA: Mengambil kolom ke-3 ===
    exp_date=$(echo "$IZIN" | grep -w "$MYIP" | awk '{print $3}')
    
    [ -z "$exp_date" ] && exp_date="Tidak Terdaftar"
    source /usr/bin/kyt/var.txt
    
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e " \e[1;97;101m         KELOLA BOT TELEGRAM         \e[0m"
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "IP VPS     : $MYIP"
    echo -e "Status Bot : $(check_status)"
    echo -e "Expired    : ${YELLOW}$exp_date${NC}"
    echo -e "Token      : ${BOT_TOKEN}"
    echo -e "Admin ID   : ${ADMIN}"
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e " [1] Cek Log Bot   [2] Restart Bot"
    echo -e " [3] Edit Config   [4] Update Script"
    echo -e " [x] Keluar"
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    read -p "Pilih opsi: " opt
    case $opt in
        1) journalctl -u kyt -f --no-pager;;
        2) sudo systemctl restart kyt; echo "Bot direstart."; sleep 1;;
        3) nano /usr/bin/kyt/var.txt; sudo systemctl restart kyt; echo "Config diubah & bot direstart."; sleep 1;;
        4) cd /usr/bin; wget -q -O u.zip https://github.com/hokagelegend9999/alpha.v2/raw/refs/heads/main/bot/kyt.zip && unzip -o u.zip && rm -f u.zip; sudo systemctl restart kyt; echo "Script diupdate & bot direstart."; sleep 1;;
        x|X) exit 0;;
        *) echo -e "${RED}Opsi tidak valid!${NC}"; sleep 1;;
    esac
done
EOF
chmod +x /usr/local/sbin/menu-bot

# --- PESAN TERAKHIR ---
clear
echo -e "${GREEN}===============================================${NC}"
echo -e "        INSTALASI BERSIH BOT SELESAI"
echo -e "${GREEN}===============================================${NC}"
echo -e "\nBot Telegram Anda sekarang sudah aktif."
echo -e "Untuk mengelola bot, ketik perintah di bawah ini:"
echo -e "${YELLOW}menu-bot${NC}\n"
