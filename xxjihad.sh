#!/bin/bash
###############################################################################
#  XxXjihad :: MAIN ENTRY POINT v8.2 (Fixed)                                  #
#  Installation and Main Menu Loader                                          #
#  FIXED: Loader Errors, Old Version Cleanup, REPO_BASE                       #
###############################################################################

REPO_BASE="https://raw.githubusercontent.com/mahmmedateer67-hash/XxXjihad-Ultima-Final-V8-Fixed/master"
LIB_DIR="/usr/local/lib/xxjihad"
BIN_DIR="/usr/local/bin"
ETC_DIR="/etc/xxjihad"

# 1. Check Root
[[ $EUID -ne 0 ]] && { echo "Error: Must run as root"; exit 1; }

# 2. Force Cleanup of Old Version (as requested)
echo "[INFO] Cleaning up old version components..."
systemctl stop zivpn falconproxy xxjihad-dnstt haproxy nginx 2>/dev/null
rm -rf "$LIB_DIR" "$ETC_DIR" "$BIN_DIR/xxjihad" "$BIN_DIR/dnstt-server"

# 3. Fresh Installation
echo "--- Installing XxXjihad-Ultima-Final-V8 (Fixed Version) ---"

# Verbose Update
echo "[INFO] Updating system packages..."
apt-get update -qq

mkdir -p "$LIB_DIR" "$ETC_DIR/configs" "$ETC_DIR/db" "$ETC_DIR/banners"

# Download Core Files
echo "[INFO] Downloading core files..."
wget -q -O "$LIB_DIR/loader.sh" "$REPO_BASE/lib/loader.sh"

# Download Modules (Encrypted)
for mod in menu-system user-manager dnstt-core ssl-tunnel protocols net-optimizer; do
    echo "[INFO] Downloading module: $mod..."
    wget -q -O "$LIB_DIR/${mod}.enc" "$REPO_BASE/lib/${mod}.enc"
done

# Download Key
echo "[INFO] Downloading security key..."
wget -q -O "$ETC_DIR/configs/.key" "$REPO_BASE/configs/.key"

# Download Binaries
echo "[INFO] Downloading binaries..."
mkdir -p "$BIN_DIR"
# Check architecture for dnstt-server
arch=$(uname -m)
if [[ "$arch" == "x86_64" ]]; then
    wget -q -O "$BIN_DIR/dnstt-server" "https://dnstt.network/dnstt-server-linux-amd64"
else
    wget -q -O "$BIN_DIR/dnstt-server" "https://dnstt.network/dnstt-server-linux-arm64"
fi
chmod +x "$BIN_DIR/dnstt-server"

# Create Main Command
cat > "$BIN_DIR/xxjihad" <<'EOF'
#!/bin/bash
LIB_DIR="/usr/local/lib/xxjihad"
source "$LIB_DIR/loader.sh"
main_menu
EOF
chmod +x "$BIN_DIR/xxjihad"

# Initial SSH Fix
echo "[INFO] Configuring SSH..."
sed -i "/ForceCommand/d" /etc/ssh/sshd_config 2>/dev/null
systemctl reload sshd 2>/dev/null

echo "Installation Complete! Type 'xxjihad' to start."
exit 0
