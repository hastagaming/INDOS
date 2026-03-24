#!/bin/bash

# Warna Neon INDOS
C="\e[1;36m"; G="\e[1;32m"; W="\e[1;37m"; R="\e[0m"; Y="\e[1;33m"

clear
echo -e "${C}─────────────────────────────────────${R}"
echo -e "${G}     INSTALASI INDOS NATIVE (V2.5)${R}"
echo -e "${C}─────────────────────────────────────${R}"

# Fungsi Sinkronisasi GitHub dengan Penanganan Konflik
git_sync() {
    echo -e "\n${Y}[*] Menyinkronkan ke GitHub (Auto-Rebase)...${R}"
    if [ -d ".git" ]; then
        git add .
        git commit -m "Update INDOS: $(date +'%Y-%m-%d %H:%M')" 2>/dev/null
        
        echo -e "${C}[>] Menarik pembaruan dari cloud...${R}"
        # Mencoba rebase, jika gagal langsung coba continue/skip
        if ! git pull --rebase origin main; then
            echo -e "${R}[!] Terdeteksi konflik! Mencoba melanjutkan...${R}"
            git add .
            git rebase --continue 2>/dev/null || git rebase --skip
        fi
        
        echo -e "${C}[>] Mendorong perubahan ke GitHub...${R}"
        git push origin main
        echo -e "${G}[+] GitHub Berhasil Diperbarui!${R}"
    else
        echo -e "${R}[!] Folder .git tidak ditemukan. Lewati git sync.${R}"
    fi
}

install_indos() {
    echo -e "\n${Y}[*] Memeriksa paket PRoot dasar...${R}"
    pkg install proot -y > /dev/null 2>&1
    
    # Cek Storage: Hanya minta izin jika folder storage belum ada
    if [ ! -d "$HOME/storage" ]; then
        echo -e "${Y}[*] Meminta izin akses penyimpanan...${R}"
        termux-setup-storage
        sleep 2
    else
        echo -e "${G}[V] Izin penyimpanan sudah aktif.${R}"
    fi

    echo -e "${Y}[*] Membangun file sistem INDOS...${R}"
    TARGET="$HOME/.indos-rootfs"
    
    # Bersihkan sistem lama dan siapkan struktur
    rm -rf $TARGET
    mkdir -p $TARGET/bin $TARGET/etc $TARGET/root $TARGET/tmp $TARGET/sdcard
    
    # Salin isi rootfs dari folder projek kamu
    if [ -d "rootfs" ]; then
        cp -r rootfs/* $TARGET/
    fi
    
    # --- JANTUNG SISTEM (Fix Path & Identity) ---
    chmod +x $TARGET/bin/busybox
    ln -sf busybox $TARGET/bin/sh
    echo "root:x:0:0:root:/root:/bin/sh" > $TARGET/etc/passwd
    echo "root:x:0:" > $TARGET/etc/group
    # --------------------------------------------

    echo -e "${Y}[*] Merakit Kernel Peluncur...${R}"
    cat << 'INNER_EOF' > $PREFIX/bin/indos
#!/bin/bash
clear
unset LD_PRELOAD
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
    
    chmod +x $PREFIX/bin/indos
    echo -e "${G}[+] INDOS NATIVE BERHASIL TERPASANG!${R}"
    
    # Jalankan Sinkronisasi GitHub
    git_sync
}

# Menu Interaktif
echo -e "${W}Apakah kamu mau tutorial?${R}"
echo -e "${G}1)${W} Iya"
echo -e "${R}2)${W} Tidak"
echo -ne "\n${Y}Pilih (1/2): ${R}"
read choice

if [ "$choice" == "1" ]; then
    clear
    echo -e "${G}─── TUTORIAL INDOS ───${R}"
    echo -e "${W}1. Ketik ${G}'indos'${W} untuk masuk ke OS."
    echo -e "2. Ketik ${R}'exit'${W} untuk keluar."
    echo -e "3. Folder HP ada di ${C}/sdcard${W}."
    echo -e "4. History GitHub otomatis lurus (Rebase Mode)."
    echo -e "${C}──────────────────────${R}"
    sleep 5
fi

install_indos

echo -e "\n${C}─────────────────────────────────────${R}"
echo -e "${W}Ketik ${G}\"indos\"${W} untuk memulai distronya${R}"
echo -e "${C}─────────────────────────────────────${R}"
