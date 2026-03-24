cat << 'EOF' > ~/INDOS/install.sh
#!/bin/bash

# Warna Neon
C="\e[1;36m"; G="\e[1;32m"; W="\e[1;37m"; R="\e[0m"; Y="\e[1;33m"

clear
echo -e "${C}─────────────────────────────────────${R}"
echo -e "${G}     INSTALASI INDOS (V1.0)${R}"
echo -e "${C}─────────────────────────────────────${R}"

# Fungsi Instalasi Inti
install_indos() {
    echo -e "\n${Y}[*] Memasang file sistem INDOS...${R}"
    TARGET="$PREFIX/var/lib/proot-distro/installed-rootfs/indos"
    CONFIG="$PREFIX/etc/proot-distro/indos.sh"

    rm -rf $TARGET
    mkdir -p $TARGET/bin $TARGET/etc
    cp -r rootfs/* $TARGET/
    chmod +x $TARGET/bin/busybox
    echo 'DISTRO_NAME="INDOS"' > $CONFIG
    
    # Membuat shortcut 'indos' di Termux luar
    cat << 'INNER_EOF' > $PREFIX/bin/indos
#!/bin/bash
clear
proot-distro login indos
INNER_EOF
    chmod +x $PREFIX/bin/indos

    echo -e "${G}[+] INDOS BERHASIL TERPASANG!${R}"
}

# Menu Interaktif: Apakah kamu mau tutorial?
echo -e "${W}Apakah kamu mau tutorial?${R}"
echo -e "${G}1)${W} Iya"
echo -e "${R}2)${W} Tidak"
echo -ne "\n${Y}Pilih (1/2): ${R}"
read choice

if [ "$choice" == "1" ]; then
    clear
    echo -e "${G}─── TUTORIAL INDOS ───${R}"
    echo -e "${W}1. Ketik ${G}'indos'${W} untuk masuk ke OS."
    echo -e "2. Di dalam INDOS, kamu bisa menggunakan perintah Linux dasar."
    echo -e "3. Ketik ${R}'exit'${W} untuk keluar dari INDOS."
    echo -e "${C}──────────────────────${R}"
    sleep 3
elif [ "$choice" == "2" ]; then
    echo -e "\n${Y}Oke, langsung gas instalasi!${R}"
else
    echo -e "\n${R}Pilihan tidak valid, menganggap 'Tidak'.${R}"
fi

# Jalankan Instalasi
install_indos

echo -e "\n${C}─────────────────────────────────────${R}"
echo -e "${W}Ketik ${G}\"indos\"${W} untuk memulai distronya${R}"
echo -e "${C}─────────────────────────────────────${R}"
EOF

chmod +x ~/INDOS/install.sh