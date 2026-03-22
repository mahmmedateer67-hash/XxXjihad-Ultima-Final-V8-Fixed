#!/bin/bash
###############################################################################
#  XxXjihad :: MAIN ENTRY POINT v8.0                                          #
#  Installation and Main Menu Loader                                          #
#  FIXED: Verbose Installation (apt-get details)                              #
###############################################################################

REPO_BASE="https://raw.githubusercontent.com/jamal7720077-debug/XxXjihad-Ultima-Final-V8/master"
LIB_DIR="/usr/local/lib/xxjihad"
BIN_DIR="/usr/local/bin"
ETC_DIR="/etc/xxjihad"

# 1. Check Root
[[ $EUID -ne 0 ]] && { echo "Error: Must run as root"; exit 1; }

# 2. Installation Check
if [[ ! -f "$BIN_DIR/xxjihad" ]]; then
    echo "--- Installing XxXjihad-Ultima-Final-V8 ---"
    
    # Verbose Update
    echo "[INFO] Updating system packages..."
    apt-get update
    
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
    wget -q -O "$BIN_DIR/dnstt-server" "$REPO_BASE/bin/dnstt-server"
    chmod +x "$BIN_DIR/dnstt-server"
    
    # Create Main Command
    cat > "$BIN_DIR/xxjihad" <<EOF
#!/bin/bash
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
fi

# 3. Load and Run
source "$LIB_DIR/loader.sh"
main_menu
