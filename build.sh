#!/bin/bash -e

export KERNEL_VERSION=$1
export KERNEL_MAIN=$2

#
# dependencies
#
echo "[+] Checking / installing dependencies..."
sudo apt-get -q update
sudo apt install gcc make bc build-essential libelf-dev libssl-dev 
sudo apt install bison flex initramfs-tools qemu-system-x86 cpio
sudo apt install git-core libncurses5-dev dwarves zstd

#
# linux kernel
#

echo "[+] Downloading kernel..."
wget -v -c https://cdn.kernel.org/pub/linux/kernel/v$KERNEL_MAIN/linux-$KERNEL_VERSION.tar.gz
[ -e linux-$KERNEL_VERSION ] || tar xzf linux-$KERNEL_VERSION.tar.gz

echo "[+] Building kernel..."
make -C linux-$KERNEL_VERSION defconfig
echo "CONFIG_NET_9P=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_NET_9P_DEBUG=n" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_9P_FS=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_9P_FS_POSIX_ACL=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_9P_FS_SECURITY=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_NET_9P_VIRTIO=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_VIRTIO_PCI=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_VIRTIO_BLK=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_VIRTIO_BLK_SCSI=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_VIRTIO_NET=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_VIRTIO_CONSOLE=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_HW_RANDOM_VIRTIO=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_DRM_VIRTIO_GPU=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_VIRTIO_PCI_LEGACY=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_VIRTIO_BALLOON=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_VIRTIO_INPUT=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_CRYPTO_DEV_VIRTIO=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_BALLOON_COMPACTION=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_STACKTRACE_SUPPORT=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_STACKTRACE=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_PCI=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_PCI_HOST_GENERIC=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_GDB_SCRIPTS=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_DEBUG_INFO=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_DEBUG_INFO_REDUCED=n" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_DEBUG_INFO_SPLIT=n" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_DEBUG_FS=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_DEBUG_INFO_DWARF4=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_DEBUG_INFO_BTF=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_FRAME_POINTER=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_DEBUG_INFO_COMPRESSED=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_KASAN = y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_DEVTMPFS=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_KALLSYMS_ALL=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_POSIX_MQUEUE=y" >> linux-$KERNEL_VERSION/.config
echo "CONFIG_POSIX_MQUEUE_SYSCTL=y" >> linux-$KERNEL_VERSION/.config


sed -i 'N;s/WARN("missing symbol table");\n\t\treturn -1;/\n\t\treturn 0;\n\t\t\/\/ A missing symbol table is actually possible if its an empty .o file.  This can happen for thunk_64.o./g' linux-$KERNEL_VERSION/tools/objtool/elf.c

sed -i 's/unsigned long __force_order/\/\/ unsigned long __force_order/g' linux-$KERNEL_VERSION/arch/x86/boot/compressed/pgtable_64.c

make -C linux-$KERNEL_VERSION -j$(nproc) bzImage
make -C linux-$KERNEL_VERSION -j$(nproc) modules

#
# Copy the bzImage to kerenl directory
#
cp linux-$KERNEL_VERSION/arch/x86/boot/bzImage ./kernel/arch/x86/boot/
