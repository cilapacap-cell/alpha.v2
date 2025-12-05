import telebot
import json
import os
import subprocess
import uuid
import random
import string
import datetime
from telebot.types import InlineKeyboardMarkup, InlineKeyboardButton

# ==========================================
# KONFIGURASI PATH & DATABASE
# ==========================================
DIR_MAIN = '/etc/alpha-store'
CONFIG_FILE = f'{DIR_MAIN}/config.json'
DB_USERS = f'{DIR_MAIN}/users_db.json'

# KONFIGURASI HARGA & DEFAULT
PRICES = {
    "ssh": 5000,
    "vmess": 5000,
    "vless": 5000,
    "trojan": 5000
}
WS_PATH = "/ssh"  # Sesuaikan dengan settingan Nginx/Haproxy Anda

# Load Config
try:
    with open(CONFIG_FILE, 'r') as f:
        config = json.load(f)
    BOT_TOKEN = config['bot_token']
    ADMIN_ID = str(config['admin_id'])
    # Ambil IP/Domain VPS otomatis
    try:
        DOMAIN = config.get('domain', subprocess.check_output("curl -s ipv4.icanhazip.com", shell=True).decode().strip())
    except:
        DOMAIN = "127.0.0.1"
except Exception as e:
    print(f"Error Loading Config: {e}")
    # Default dummy agar script tidak crash saat installasi awal
    BOT_TOKEN = "TOKEN_DUMMY" 
    ADMIN_ID = "0"
    DOMAIN = "127.0.0.1"

bot = telebot.TeleBot(BOT_TOKEN)

# ==========================================
# SISTEM DATABASE (SALDO)
# ==========================================
if not os.path.exists(DB_USERS):
    with open(DB_USERS, 'w') as f:
        json.dump({}, f)

def load_db():
    try:
        with open(DB_USERS, 'r') as f:
            return json.load(f)
    except: return {}

def save_db(data):
    with open(DB_USERS, 'w') as f:
        json.dump(data, f, indent=4)

def get_balance(user_id):
    db = load_db()
    return db.get(str(user_id), {}).get('balance', 0)

def reduce_balance(user_id, amount):
    db = load_db()
    uid = str(user_id)
    if uid not in db: return False
    if db[uid]['balance'] >= amount:
        db[uid]['balance'] -= amount
        save_db(db)
        return True
    return False

def add_balance(user_id, amount):
    db = load_db()
    uid = str(user_id)
    if uid not in db:
        db[uid] = {'balance': 0, 'username': 'Unknown'}
    db[uid]['balance'] += amount
    save_db(db)

# ==========================================
# LOGIKA PEMBUATAN AKUN (SSH & XRAY)
# ==========================================
def get_random_password(length=6):
    return ''.join(random.choice(string.ascii_letters + string.digits) for i in range(length))

def restart_service(service_name):
    os.system(f'systemctl restart {service_name}')

def create_ssh_logic(username, password, days):
    try:
        cmd_date = f"date -d '+{days} days' +'%Y-%m-%d'"
        exp_date = subprocess.check_output(cmd_date, shell=True).decode().strip()
        
        # Command Linux Useradd
        os.system(f"useradd -e {exp_date} -s /bin/false -M {username}")
        os.system(f"echo '{username}:{password}' | chpasswd")
        
        return True, exp_date
    except Exception as e:
        print(f"Error Create SSH: {e}")
        return False, None

def create_xray_logic(protocol, username, days):
    try:
        u_id = str(uuid.uuid4())
        path_config = '/etc/xray/config.json'
        
        with open(path_config, 'r') as f:
            data = json.load(f)
        
        found = False
        for inbound in data['inbounds']:
            if inbound['protocol'] == protocol:
                email = f"{username}@{protocol}"
                client_data = {"id": u_id, "email": email}
                if protocol == "vmess":
                    client_data["alterId"] = 0
                
                inbound['settings']['clients'].append(client_data)
                found = True
                break
        
        if found:
            with open(path_config, 'w') as f:
                json.dump(data, f, indent=2)
            restart_service('xray')
            return True, u_id
        else:
            return False, "Protocol not found"
    except Exception as e:
        return False, str(e)

# ==========================================
# HANDLER BOT TELEGRAM
# ==========================================

@bot.message_handler(commands=['start', 'menu'])
def menu_handler(message):
    uid = str(message.chat.id)
    name = message.from_user.first_name
    
    # Auto Register
    db = load_db()
    if uid not in db:
        db[uid] = {'balance': 0, 'username': name}
        save_db(db)
    
    saldo = db[uid]['balance']
    
    markup = InlineKeyboardMarkup()
    markup.row_width = 2
    markup.add(
        InlineKeyboardButton(f"🛒 SSH (Rp {PRICES['ssh']})", callback_data="buy_ssh"),
        InlineKeyboardButton(f"🛒 VMESS (Rp {PRICES['vmess']})", callback_data="buy_vmess"),
        InlineKeyboardButton(f"🛒 VLESS (Rp {PRICES['vless']})", callback_data="buy_vless"),
        InlineKeyboardButton("👤 Info Akun", callback_data="info_user")
    )
    
    if uid == ADMIN_ID:
        markup.add(InlineKeyboardButton("👑 Topup User (Admin)", callback_data="admin_topup"))

    text = (
        f"<b>🏪 ALPHA STORE PANEL</b>\n"
        f"━━━━━━━━━━━━━━━━━━━\n"
        f"👋 Halo, <b>{name}</b>\n"
        f"💰 Saldo Anda: <b>Rp {saldo:,}</b>\n"
        f"━━━━━━━━━━━━━━━━━━━\n"
        f"Silakan pilih layanan yang ingin dibeli:"
    )
    bot.reply_to(message, text, parse_mode='HTML', reply_markup=markup)

@bot.callback_query_handler(func=lambda call: True)
def callback_logic(call):
    uid = call.message.chat.id
    
    if call.data == "info_user":
        bal = get_balance(uid)
        bot.answer_callback_query(call.id, f"Saldo Anda: Rp {bal:,}", show_alert=True)

    elif call.data.startswith("buy_"):
        tipe = call.data.split("_")[1]
        harga = PRICES[tipe]
        saldo = get_balance(uid)
        
        if saldo < harga:
            bot.answer_callback_query(call.id, "❌ Saldo tidak cukup! Hubungi Admin.", show_alert=True)
            return

        msg = bot.send_message(uid, f"<b>🔹 BELI {tipe.upper()}</b>\n\nMasukkan Username yang diinginkan:", parse_mode='HTML')
        bot.register_next_step_handler(msg, process_purchase, tipe, harga)

    elif call.data == "admin_topup":
        msg = bot.send_message(uid, "<b>👑 ADMIN TOPUP</b>\n\nFormat: <code>ID_USER JUMLAH</code>", parse_mode='HTML')
        bot.register_next_step_handler(msg, process_topup)

def process_purchase(message, tipe, harga):
    try:
        user_req = message.text.strip().replace(" ", "")
        uid = message.chat.id
        
        # Potong Saldo
        if not reduce_balance(uid, harga):
            bot.reply_to(message, "❌ Transaksi Gagal: Saldo Kurang.")
            return

        bot.send_message(uid, "⏳ Sedang memproses transaksi...")
        
        # --- PROSES SSH ---
        if tipe == "ssh":
            passwd = get_random_password(6)
            success, exp = create_ssh_logic(user_req, passwd, 30)
            
            if success:
                res = f"""
<b>━━━━━━━━━━━━━━━━━━━━━━━━━━━━</b>
<b>👑 SSH WEBSOCKET ACCOUNT</b>
<b>━━━━━━━━━━━━━━━━━━━━━━━━━━━━</b>

<b>👤 Username :</b> <code>{user_req}</code>
<b>🔑 Password :</b> <code>{passwd}</code>
<b>🌐 Host/IP  :</b> <code>{DOMAIN}</code>
<b>📅 Expired  :</b> <code>{exp}</code>

<b>⚙️ DETAIL PORT & PATH</b>
<b>• SSH OpenSSH :</b> <code>22</code>
<b>• SSH Dropbear:</b> <code>109, 143</code>
<b>• SSH WS HTTP :</b> <code>80, 2082, 8080</code>
<b>• SSH WS SSL  :</b> <code>443, 2053</code>
<b>• WS Path     :</b> <code>{WS_PATH}</code>

<b>🧩 FORMAT PAYLOAD (HTTP/WS)</b>
<code>GET {WS_PATH} HTTP/1.1[crlf]Host: {DOMAIN}[crlf]Upgrade: websocket[crlf][crlf]</code>

<b>🔗 FORMAT KONEKSI</b>
<b>• WS :</b> <code>{DOMAIN}:80@{user_req}:{passwd}</code>
<b>• SSL:</b> <code>{DOMAIN}:443@{user_req}:{passwd}</code>
<b>• UDP:</b> <code>{DOMAIN}:1-65535@{user_req}:{passwd}</code>

<b>📊 INFO LAIN</b>
<b>• Limit IP :</b> <code>2 Device</code>
<b>• Harga    :</b> <code>Rp {harga:,}</code>
<b>━━━━━━━━━━━━━━━━━━━━━━━━━━━━</b>
"""
            else:
                add_balance(uid, harga) # Refund
                res = "❌ Gagal membuat SSH. Saldo dikembalikan."

        # --- PROSES XRAY (VMESS/VLESS) ---
        elif tipe in ["vmess", "vless"]:
            success, uuid_res = create_xray_logic(tipe, user_req, 30)
            if success:
                if tipe == "vmess":
                    # Generate Link Vmess JSON
                    vmess_config = {
                        "v": "2", "ps": user_req, "add": DOMAIN, "port": "443", "id": uuid_res,
                        "aid": "0", "net": "ws", "path": f"/{tipe}", "type": "none", "host": DOMAIN, "tls": "tls"
                    }
                    import base64
                    link = "vmess://" + base64.b64encode(json.dumps(vmess_config).encode()).decode()
                else:
                    link = f"vless://{uuid_res}@{DOMAIN}:443?path=%2F{tipe}&security=tls&encryption=none&type=ws#{user_req}"
                
                res = (
                    f"<b>✅ TRANSAKSI BERHASIL!</b>\n"
                    f"━━━━━━━━━━━━━━━━━━━\n"
                    f"<b>Layanan:</b> {tipe.upper()}\n"
                    f"<b>Remarks:</b> <code>{user_req}</code>\n"
                    f"<b>Domain:</b> <code>{DOMAIN}</code>\n"
                    f"<b>UUID:</b> <code>{uuid_res}</code>\n"
                    f"<b>Harga:</b> Rp {harga:,}\n"
                    f"━━━━━━━━━━━━━━━━━━━\n"
                    f"<code>{link}</code>"
                )
            else:
                add_balance(uid, harga)
                res = f"❌ Gagal membuat {tipe.upper()}. Saldo dikembalikan."

        bot.reply_to(message, res, parse_mode='HTML')

    except Exception as e:
        bot.reply_to(message, f"Error: {e}")

def process_topup(message):
    try:
        data = message.text.split()
        target_id = data[0]
        amount = int(data[1])
        
        add_balance(target_id, amount)
        bot.reply_to(message, f"✅ Berhasil tambah saldo <b>Rp {amount:,}</b> ke ID <code>{target_id}</code>", parse_mode='HTML')
    except:
        bot.reply_to(message, "❌ Format salah. Gunakan: ID JUMLAH")

# MAIN LOOP
print("Bot Started...")
while True:
    try:
        bot.polling(none_stop=True)
    except Exception as e:
        print(f"Error Polling: {e}")
