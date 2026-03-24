#!/bin/bash

# Warna Neon INDOS
C="\e[1;36m"; G="\e[1;32m"; W="\e[1;37m"; R="\e[0m"; Y="\e[1;33m"

clear
echo -e "${C}─────────────────────────────────────${R}"
echo -e "${G}     INSTALASI INDOS NATIVE (V2.6)${R}"
echo -e "${C}─────────────────────────────────────${R}"

# Fungsi Sinkronisasi GitHub
git_sync() {
    if [ -d ".git" ]; then
        echo -e "\n${Y}[*] Syncing GitHub...${R}"
        git add .
        git commit -m "Fix Android 15 Exec Error" 2>/dev/null
        git pull --rebase origin main 2>/dev/null || git rebase --skip
        git push origin main 2>/dev/null
    fi
}

install_indos() {
    echo -e "\n${Y}[*] Memasang mesin PRoot...${R}"
    pkg install proot -y > /dev/null 2>&1
    
    # Cek Storage
    [ ! -d "$HOME/storage" ] && termux-setup-storage

    # Lokasi TARGET diubah ke folder standar agar tidak kena blokir kernel
    TARGET="$HOME/indos-rootfs"
    
    echo -e "${Y}[*] Membangun sistem di $TARGET...${R}"
    rm -rf $TARGET
    mkdir -p $TARGET/bin $TARGET/etc $TARGET/root $TARGET/tmp $TARGET/sdcard
    
    if [ -d "rootfs" ]; then
        cp -r rootfs/* $TARGET/
    fi
    
    # Fix Executable & Path
    # Kita salin busybox langsung ke /bin/sh agar tidak perlu symlink yang sering error di A15
    cp $TARGET/bin/busybox $TARGET/bin/sh
    chmod 755 $TARGET/bin/busybox
    chmod 755 $TARGET/bin/sh
    
    echo "root:x:0:0:root:/root:/bin/sh" > $TARGET/etc/passwd
    echo "root:x:0:" > $TARGET/etc/group

    # Membuat Peluncur dengan Flag Android 15
    echo -e "${Y}[*] Merakit Peluncur Native...${R}"
    cat << 'INNER_EOF' > $PREFIX/bin/indos
#!/bin/bash
# Hapus variabel yang mengganggu kernel
unset LD_PRELOAD
export PROOT_SKIP_CLEANUP=1

# Menjalankan PRoot dengan mode kompatibilitas tinggi
proot --link2symlink \
      -0 \
      -r $HOME/indos-rootfs \
      -b /dev \
      -b /proc \
      -b /sys \
      -b /sdcard \
      -b $HOME \
      -w / \
      /bin/sh
INNER_EOF
    
    chmod +x $PREFIX/bin/indos
    echo -e "${G}[+] INDOS BERHASIL TERPASANG!${R}"
    git_sync
}

install_indos

echo -e "\n${C}─────────────────────────────────────${R}"
echo -e "${W}Ketik ${G}\"indos\"${W} untuk memulai${R}"
echo -e "${C}─────────────────────────────────────${R}"
