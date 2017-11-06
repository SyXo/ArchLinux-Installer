#!/bin/bash
read -p "(config.sh) Enter to continue: "

## 必要设置
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock -- systohc --utc
echo "zh_CN.UTF-8 UTF-8
zh_TW.UTF-8 UTF-8
en_US.UTF-8 UTF-8
" >> /etc/locale.gen
## echo Edit /etc/locale.gen ...
## nano /etc/locale.gen
locale-gen
echo LANG=zh_cn.UTF-8 > /etc/locale.conf
read -p "Input yout hostname: " HOSTNAME
echo $HOSTNAME > /etc/hostname
echo Change yout root password
passwd
## 安装引导
read -p "Do you use efi to boot ? (y or Enter: " TMP
if [ "$TMP" == y ]
then
	TMP=n
	while [ "$TMP" == n ]
	do
		pacman -S --noconfirm grub efibootmgr os-prober
		grub-install --target=x86_64-efi --efi-directory=/boot -- bootloader-id=ArchLinux
		grub-mkconfig -o /boot/grub/grub.cfg
	read -p "Successfully installed ? (n or Enter: " TMP
	done
else
	TMP=n
	while [ "$TMP" == n ]
	do
		pacman -S --noconfirm grub os-prober&& fdisk -l
		read -p "Input the disk you want to install the grub: " GRUB
		grub-install --target=i386-pc $GRUB
		grub-mkconfig -o /boot/grub/grub.cfg
		read -p "Successfully installed ? (n or Enter: " TMP
	done
fi
## 安装显卡驱动
TMP = n
while [ "$TMP" == n ]
do
	VIDEO=5
	while [ $VIDEO != 1 && $VIDEO != 2 && $VIDEO != 3 && $VIDEO != 4 ]
	do
		echo "What is your video card ?
[1] Intel
[2] NVIDIA
[3] Intel and NVIDIA
[4] AMD and ATI"
		read VIDEO
		if [ $VIDEO == 1 ]
		then
			pacman -S --noconfirm xf86-video-intel -y
		elif [ $VIDEO == 2 ]
		then
			VERSION = 4
			while [ $VERSION != 1 && VERSION != 2 && VERSION != 3 ]
			do
				echo " Version of nvidia-driver to install:
[1] GeForce-8 or newer
[2] GeForce-6/7
[3] Older
"
				read VERSION
				if [ $VERSION == 1 ]
				then
					pacman -S --noconfirm nvidia -y
				elif [ $VERSION == 2 ]
				then
					pacman -S --noconfirm nvidia-304xx -y
				elif [ $VERSION == 3 ]
					pacman -S --noconfirm nvidia-340xx -y
				else
					echo "Error ! Input the number again: "
				fi
			done
		elif [ $VIDEO == 3 ]
		then
			pacman -S --noconfirm bumblebee xf86-video-intel -y
			systemctl enable bumblebeed
			VERSION=4
			while [ $VERSION != 1 && VERSION != 2 && VERSION != 3 ]
			do
				echo " Version of nvidia-driver to install:
[1] GeForce-8 or newer
[2] GeForce-6/7
[3] Older
"
				read VERSION
				if [ $VERSION == 1 ]
				then
					pacman -S --noconfirm nvidia -y
				elif [ $VERSION == 2 ]
				then
					pacman -S --noconfirm nvidia-304xx -y
				elif [ $VERSION == 3 ]
					pacman -S --noconfirm nvidia-340xx -y
				else
					echo "Error ! Input the number again: "
				fi
			done
		elif [ $VIDEO == 4 ]
		then
			pacman -S --noconfirm xf86-video-ati -y
		else
			echo "Error ! Input the number again: "
		fi
	done
	read -p "Successful installed ? (n or Enter: " TMP
done
## 安装必要软件/简单配置
echo "
[archlinuxcn]
Server = http://mirrors.ustc.edu.cn/archlinuxcn/\$arch
" >> /etc/pacman.conf
TMP=n
while [ "$TMP" == n ]
do
	pacman -Syu && pacman -S --noconfirm archlinuxcn-keyring && pacman -S --noconfirm networkmanager dialog wpa_supplicant netctl wireless_tools xorg-server yaourt wqy-zenhei sudo firefox firefox-i18n-zh-cn fcitx-sogoupinyin
	systemctl enable NetworkManager
	read -p "Do you hava bluetooth ? (y or Enter: " TMP
	if [ "$TMP" == y ]
	then
		pacman -S --noconfirm bluez blueman && systemctl enable bluetooth
	fi
	read -p "Successful installed ? (n or Enter: " TMP
done
## 安装桌面环境
TMP=n
while [ "$TMP" == n ]
do
	echo -e "\033[31m Whick desktop do you want to install: \033[0m"
	DESKTOP = 0
	while [ $DESKTOP != 1 && $DESKTOP != 2 && $DESKTOP != 3 && $DESKTOP != 4 && $DESKTOP != 5 && $DESKTOP != 6 && $DESKTOP != 7 && $DESKTOP != 8 && $DESKTOP != 9 && $DESKTOP != 10 ]
	do
echo "[1]  Gnome
[2] Kde
[3] Lxde
[4] Lxqt
[5] Mate
[6] Xfce
[7] Deepin
[8] Budgie
[9] Cinnamon
[10] i3wm"
		read DESKTOP
		case $DESKTOP in
		1) pacman -S --noconfirm gnome
		;;
		2) pacman -S --noconfirm plasma kdebase kdeutils kdegraphics kde-l10n-zh_cn sddm
		;;
		3) pacman -S --noconfirm lxde lightdm lightdm-gtk-greeter
		;;
		4) pacman -S --noconfirm lxqt lightdm lightdm-gtk-greeter
		;;
		5) pacman -S --noconfirm mate mate-extra lightdm lightdm-gtk-greeter
		;;
		6) pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
		;;
		7) pacman -S --noconfirm deepin deepin-extra lightdm lightdm-gtk-greeter && sed -i '108s/#greeter-session=example-gtk-gnome/greeter-session=lightdm-deepin-greeter/' /etc/lightdm/lightdm.conf
		;;
		8) pacman -S--noconfirm  budgie-desktop lightdm lightdm-gtk-greeter
		;;
		9) pacman -S --noconfirm cinnamon lightdm lightdm-gtk-greeter
		;;
		10) pacman -S --noconfirm i3 rofi rxvt-unicode lightdm lightdm-gtk-greeter
		;;
		*) echo Error ! Input the number again
		;;
		esac
	done
	read -p "Successfully installed ? (n or Enter  " TMP
done
## 建立用户
read -p "Input the username you want to use: " USER
useradd -m -g wheel $USER
passwd $USER
usermod -aG root,bin,daemon,tty,disk,network,video,audio $USER
if [ $VIDEO == 3 ]
then
	gpasswd -a $USER bumblebee
fi
if [ $DESKTOP == 1 ]
then
	gpasswd -a $USER gdm
	systemctl enable gdm
fi
if [ $DESKTOP == 2 ]
then
	gpasswd -a $USER sddm
fi
else
	gpasswd -a $USER lightdm
	systemctl enable lightdm
fi
sed -i 's/\# \%wheel ALL=(ALL) ALL/\%wheel ALL=(ALL) ALL/g' /etc/sudoers
## 自定义
read -p "Enter to run your own command (Input exit to quit: "
bash
