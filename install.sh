cat << 'EOF' > ~/INDOS/install.sh
#!/bin/bash

# Warna Neon INDOS
C="\e[1;36m"; G="\e[1;32m"; W="\e[1;37m"; R="\e[0m"; Y="\e[1;33m"

clear
echo -e "${C}─────────────────────────────────────${R}"
echo -e "${G}     INSTALASI INDOS NATIVE (V2.1)${R}"
echo -e "${C}─────────────────────────────────────${R}"

# Fungsi Instalasi Inti (Native PRoot + SDCard)
install_indos() {
    echo -e "\n${Y}[*] Memeriksa paket PRoot dasar...${R}"
    pkg install proot -y > /dev/null 2>&1
    
    # Meminta izin akses penyimpanan HP
    termux-setup-storage

    echo -e "${Y}[*] Membangun file sistem INDOS...${R}"
    TARGET="$HOME/.indos-rootfs"
    
    # Bersihkan sistem lama dan buat baru
    rm -rf $TARGET
    mkdir -p $TARGET/sdcard
    
    # Copy seluruh isi folder rootfs ke folder instalasi
    cp -r rootfs/* $TARGET/
    
    # Wajib untuk Android 15: Beri izin eksekusi biner utama
    chmod +x $TARGET/bin/busybox
    
    # Membuat shortcut 'indos' dengan eksekusi PRoot mentah & Mount SDCard
    echo -e "${Y}[*] Merakit Kernel Peluncur...${R}"
    cat << 'INNER_EOF' > $PREFIX/bin/indos
#!/bin/bash
clear
# Hapus variabel Termux agar tidak bentrok
unset LD_PRELOAD

# Menjalankan mesin PRoot murni dengan binding ke SDCard
proot --link2symlink \
      -0 \
      -r $HOME/.indos-rootfs \
      -b /dev \
      -b /proc \
      -b /sys \
      -b /sdcard \
      -w / \
      /bin/sh
INNER_EOF
    
    # Berikan izin eksekusi pada peluncur
    chmod +x $PREFIX/bin/indos

    echo -e "${G}[+] INDOS NATIVE BERHASIL TERPASANG!${R}"
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
    echo -e "2. Kamu bisa akses file HP di folder ${C}/sdcard${W}."
    echo -e "3. Gunakan perintah Linux dasar (ls, cd, mkdir, dll)."
    echo -e "4. Ketik ${R}'exit'${W} untuk keluar dari INDOS."
    echo -e "${C}──────────────────────${R}"
    sleep 5
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

# Beri izin eksekusi ke script utama
chmod +x ~/INDOS/install.sh