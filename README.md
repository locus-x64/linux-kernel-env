# Linux Kernel Exploitation Lab

This repository contains the materials for the Linux Kernel Exploitation Lab. Thanks to @deathNet123 for this lab.
It uses qemu with debian images to simulate a kernel environment.

## Setup

### Make debian image

```bash
./create-image.sh -d bookworm -f full
```

### Kernel Compilation

This script will automatically downlaod the specified kernel version and compile it with required debug symbols and configurations. For instance I have used 6.1.38 version of the kernel.

```bash
./build.sh 6.1.38 6.x
```

## Launching the VM

```bash
./startvm
```

## Interacting with the VM

To copy the files to the VM, you can use following command:

```bash
./copy2vm <file>
```

And this will copy the file to the /home/user directory of the VM.

## Intstall 3rd party tool
By mounting the filesystem img file and then chroot into it.

Mount the filesystem
```bash
cd img && mkdir mountpt
sudo mount bookworm.img mountpt/
```

Chroot into the filesystem
```bash
cd mountpt
sudo chroot .
```
Install the dependencies, utilities or library
```bash
apt install <pkg-name>
```
