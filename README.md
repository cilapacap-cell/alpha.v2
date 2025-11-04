#### DOWNGRADE XRAY 


# 1. Stop service Xray terlebih dahulu
sudo systemctl stop xray
# atau jika nama servicenya berbeda: sudo systemctl stop xray-core

# 2. Backup binary lama (misalnya di /usr/local/bin/xray)
sudo mv /usr/local/bin/xray /usr/local/bin/xray.bak.v25.10

# 3. Download file zip versi yang diinginkan
wget https://github.com/XTLS/Xray-core/releases/download/v25.1.30/Xray-linux-64.zip

# 4. Unzip
unzip Xray-linux-64.zip
# misalnya akan menghasilkan file bernama “xray”

# 5. Pasang binary baru
sudo mv xray /usr/local/bin/xray
sudo chmod +x /usr/local/bin/xray
# Pastikan owner/root sesuai: sudo chown root:root /usr/local/bin/xray

# 6. Verifikasi versi
/usr/local/bin/xray version
# Pastikan tertulis v25.1.30

# 7. Mulai kembali service
sudo systemctl start xray
sudo systemctl enable xray

# 8. Cek log & status
sudo systemctl status xray
sudo journalctl -u xray -f


