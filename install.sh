#!/bin/bash

# Warna Neon INDOS
C="\e[1;36m"; G="\e[1;32m"; W="\e[1;37m"; R="\e[0m"; Y="\e[1;33m"

clear
echo -e "${C}─────────────────────────────────────${R}"
echo -e "${G}     INSTALASI INDOS NATIVE (V2.7)${R}"
echo -e "${C}─────────────────────────────────────${R}"

# Fungsi Sinkronisasi GitHub (Hanya untuk Pemilik Repo)
git_sync() {
    # Cek apakah ini folder git dan apakah remotenya adalah hastagaming
    if [ -d ".git" ]; then
        REMOTE_URL=$(git config --get remote.origin.url)
        if [[ "$REMOTE_URL" == *"hastagaming"* ]]; then
            echo -e "\n${Y}[*] Mendeteksi Pemilik: Sinkronisasi GitHub...${R}"
            git add .
            git commit -m "Fix Android 15 compatibility & Permission: $(date +'%Y-%m-%d %H:%M')" 2>/dev/null
            
            echo -e "${C}[>] Rebase & Push...${R}"
            if ! git pull --rebase origin main; then
                git add .
                git rebase --continue 2>/dev/null || git rebase --skip
            fi
            git push origin main
            echo -e "${G}[+] GitHub Diperbarui!${R}"
        else
            echo -e "\n${W}[-] Mode Pengguna: Lewati Sinkronisasi GitHub.${R}"
        fi
    else
        echo -e "\n${W}[-] Bukan Folder Git: Lewati Sinkronisasi.${R}"
    fi
}

install_indos() {
    echo -e "\n${Y}[*] Memasang biner PRoot...${R}"
    pkg install proot -y > /dev/null 2>&1
    
    # Cek Storage
    if [ ! -d "$HOME/storage" ]; then
        echo -e "${Y}[*] Meminta izin penyimpanan...${R}"
        termux-setup-storage
        sleep 2
    fi

    # Lokasi TARGET (Gunakan folder standar, bukan folder titik demi Android 15)
    TARGET="$HOME/indos-rootfs"
    
    echo -e "${Y}[*] Membangun sistem INDOS di $TARGET...${R}"
    rm -rf $TARGET
    mkdir -p $TARGET/bin $TARGET/etc $TARGET/root $TARGET/tmp $TARGET/sdcard
    
    if [ -d "rootfs" ]; then
        cp -r rootfs/* $TARGET/
    fi
    
    # --- FIX ANDROID 15 EXECUTION ERROR ---
    # Gunakan Hard Copy Busybox ke SH, jangan pakai Symlink (ln -s) karena sering diblokir
    cp $TARGET/bin/busybox $TARGET/bin/sh
    chmod 755 $TARGET/bin/busybox
    chmod 755 $TARGET/bin/sh
    
    # Identitas Root
    echo "root:x:0:0:root:/root:/bin/sh" > $TARGET/etc/passwd
    echo "root:x:0:" > $TARGET/etc/group
    # --------------------------------------

    echo -e "${Y}[*] Merakit Kernel Peluncur...${R}"
    cat << 'INNER_EOF' > $PREFIX/bin/indos
#!/bin/bash
clear
# Hapus variabel yang mengganggu Android 15
unset LD_PRELOAD
# Jangan hapus file temp secara agresif agar tidak error Function Not Implemented
export PROOT_SKIP_CLEANUP=1

# Jalankan mesin PRoot dengan mode kompatibilitas
proot --link2symlink \
      -0 \
      -r $HOME/indos-rootfs \
      -b /dev \
      -b /proc \
      -b /sys \
      -b /sdcard \
      -w / \
      /bin/sh
INNER_EOF
    
    chmod +x $PREFIX/bin/indos
    echo -e "${G}[+] INDOS NATIVE BERHASIL TERPASANG!${R}"
    
    # Jalankan Sinkronisasi (Otomatis deteksi siapa yang pakai)
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
    echo -e "2. Akses HP ada di folder ${C}/sdcard${W}."
    echo -e "3. Fitur Auto-Git hanya aktif untuk ${G}hastagaming${W}."
    echo -e "4. Ketik ${R}'exit'${W} untuk keluar."
    echo -e "${C}──────────────────────${R}"
    sleep 5
fi

install_indos

echo -e "\n${C}─────────────────────────────────────${R}"
echo -e "${W}Ketik ${G}\"indos\"${W} untuk memulai distronya${R}"
echo -e "${C}─────────────────────────────────────${R}"
