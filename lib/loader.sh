#!/bin/bash
LIB_DIR="/usr/local/lib/xxjihad"
KEY_FILE="/etc/xxjihad/configs/.key"
RAM_DIR="/dev/shm"

load_module() {
    local module_name="$1"
    local enc_file="${LIB_DIR}/${module_name}.enc"
    local tmp_file="${RAM_DIR}/.${module_name}.$(date +%s)"
    
    if [[ -f "$enc_file" && -f "$KEY_FILE" ]]; then
        local key=$(cat "$KEY_FILE")
        openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 -pass "pass:$key" -in "$enc_file" -out "$tmp_file" 2>/dev/null
        if [[ -f "$tmp_file" ]]; then
            source "$tmp_file"
            rm -f "$tmp_file"
        fi
    fi
}

# Load all modules
load_module "menu-system"
load_module "user-manager"
load_module "dnstt-core"
load_module "ssl-tunnel"
load_module "protocols"
load_module "net-optimizer"
