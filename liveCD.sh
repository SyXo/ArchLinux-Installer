#!/bin/bash
##分区
read -p "Do yout want to adjust the partition ? (Input y to use cfdisk ro Enter to continue: " TMP
if [ "$TMP" == y ]
then
	read -p "Which disk do you want to partition ? (/dev/sdX: " DISK
	CONTINUE = y
	while [ CONTINUE == y ]
	do
		fdisk -l
		cfdisk $DISK
		read -p "Continue ? (Input y to partition ro Enter to next step: " CONTINUE
	done
fi
## /mnt
fdisk -l
read -p "Input the / mount point: " ROOT
read -p "Format it ? (y or Enter: " TMP
if [ "$TMP" == y ]
then
	read -p "Input y to use ext4 , default to use btrfs: " TMP
	if [ "$TMP" == y ]
	then
		mkfs.ext4 $ROOT --force
	else
		mkfs.btrfs $ROOT -f
	fi
fi
mount $ROOT /mnt
## /boot
read -p "Do you have the /boot mount point ? (y or Enter: " BOOT
if [ "$BOOT" == y ]
then
	fdisk -l
	read -p "Input the /boot mount point: " BOOT
	read -p "Format it ? (y or Enter: " TMP
	if [ "$TMP" == y ]
	then
		mkfs.fat -F32 $BOOT
	fi
	mkdir /mnt/boot
	mount $BOOT /mnt/boot
fi
## /home
read -p "Do you have the /home partition ? (y or Enter: " HOME
if [ "$HOME" == y ]
then
	fdisk -l
	read -p "Input the /home mount point: " HOME
	read -p "Format it ? (y or Enter: " TMP
	if [ "$TMP" == y ]
	then
		read -p "Input y to use ext4 , default to use btrfs: " TMP
		if [ "$TMP" == y ]
		then
			mkfs.ext4 $HOME --force
		else
			mkfs.btrfs $HOMR -f
		fi
	fi
fi
## swap
read -p "Do you hava the swap partition ? (y or Enter: " SWAP
if [ "$SWAP" == y ]
then fdisk -l
	read -p "Input the swap mount point: " SWAP
	read -p "Format if ? (y or Enter: " TMP
	if [ "$TMP" == y ]
	then
		mkswap $SWAP
	fi
	swapon $SWAP
fi
## 软件源
## sed -i '/Score/{/China/!{n;s/^/#/}}' /etc/pacman.d/mirrorlist 选择中国的源
TMP = y
read -p "Do yout want to edit the software sources ? (n or Enter: " TMP
	if [ "$TMP" == y ]
	then
		sed -i "s/^\b/#/g" /etc/pacman.d/mirrorlist
		nano /etc/pacman.d/mirrorlist
	fi
read -p "Edit /etc/pacman.conf ? (y or Enter: " TMP
if [ "$TMP" == y ]
then
	nano /etc/pacman.conf
fi
## 安装基本系统
TMP = n
while [ "$TMP" == n ]
do
	pacstrap /mnt base base-devel --force
	genfstab -U -p /mnt >> /mnt/etc/fstab
	cat /mnt/etc/fstab
	read -p "Edit the file [/mnt/etc/fstab] ? (y or Enter: " EDIT
	if [ "$EDIT" == y ]
	then
		nano /mnt/etc/fstab
	fi
	read -p "Successfully installed ? (n or Enter: " TMP
done
## 进入已安装的系统
wget https://raw.githubusercontent.com/youthug/ArchLinux-Installer/master/config.sh
mv config.sh /mnt/root/config.sh
chmod +x /mnt/root/config.sh
arch-chroot /mnt /root/config.sh
