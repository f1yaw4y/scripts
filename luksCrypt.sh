#!/bin/bash

#global
containername=""
########################################################################################################################################################################################################
#sudo cryptsetup luksOpen /path/to/container/file luks_device
#sudo mkdir /path/to/mount/point
#sudo mount /dev/mapper/luks_device /path/to/mount/point


#sudo umount /path/to/mount/point
#sudo cryptsetup luksClose luks_device

#global
containername=""
drive_path=""
drive_name=""
drive_mount_location=""

function home() {
clear
echo "1. Open/mount container"
echo "2. Close/unmount container"
echo "3. Create container"
echo "4. Delete container"
echo "5. Encrypt physical drive"
echo "6. Decrypt Physical drive"
echo "7. Open encrypted drive"
echo "8. Close encrypted drive"
echo "9. Format drive"
echo "10. Force unmount"
echo "11. Secure wipe"
echo "12. List all luks devices"
echo ""
echo ""
echo ""
read -p "Select an option > " option

case $option in
1) open_cont; home ;;
2) close_cont; home;;
3) create_cont; home;;
4) delete_cont; home;;
5) encrypt_drive; home;;
7) open_drive; home;;
8) close_drive; home;;
9) format_drive; home;;
11) wipe; home;;
12) list_drives; home;;
esac

}

function set_drive_variables() {
clear
if [$drive_path = ''];
then
lsblk
echo ""
echo ""
read -p "Please select a drive (sdX) > " drive_path
fi

if [$drive_name = ''];
then
clear
read -p "Please enter drive name > " drive_name
fi

if [$drive_mount_location = ''];
then
clear
read -p "Please enter your mount location > " drive_mount_location
fi
}

function wipe() {
clear
if [$drive_path = ''];
then
lsblk
echo ""
echo ""
read -p "Please select a drive (sdX) > " drive_path
fi
sudo umount /dev/$drive_path
sudo dd if=/dev/urandom of=/dev/$drive_path bs=4M status=progress
read -p "Operation complete. To go home press enter"
}

function create_cont() {
default_location="/home/"$USER
default_location=$default_location"/Documents/"
clear
read -p "Enter container name > " containername
read -p "Enter container size (GB) > " containersize
echo ""
echo "It is advised to not use root directory to create your container"
echo "Leave this field blank to accept default location (Documents)"
echo ""
read -p "Enter a location for your container > " containerlocation

if [$containerlocation = '']
then
containerlocation=$default_location
fi

containersize=$containersize"GB"

containerpath=$containerlocation$containername

clear
echo "Container name: " $containername
echo "Container size: " $containersize
echo ""
echo "Formatting and creating your container..."
echo""
sudo cryptsetup luksOpen $containerlocation luks_device
sudo mkdir /path/to/mount/point
sudo mount /dev/mapper/luks_device /path/to/mount/point
#cryptsetup -v luksFormat CONTAINER --key-file ~/mykeyfile
sudo cryptsetup -v luksFormat /root/$containername

#decrypt
sudo cryptsetup -v luksOpen /root/$containername container
#cryptsetup -v luksFormat CONTAINER --key-file ~/mykeyfile


#format
sudo mkfs -t ext4 /dev/mapper/$containername
open_cont

}

function open_cont() {

if [$(containername) = ''];
then
read -p "Enter container name > " containername
fi

#open
sudo cryptsetup -v luksOpen $containername container
#cryptsetup -v luksFormat CONTAINER --key-file ~/mykeyfile

#mount
sudo mount /dev/mapper/$containername /mnt/$containername

}

function close_cont() {
if [$containername = ''];
then
read -p "Enter container name > " containername
fi
#Unmount
sudo umount /mnt/$containername

#close
sudo cryptsetup luksClose $containername

}

function format_drive() {

clear
if [$(drive_path) = ''];
then
lsblk
echo ""
echo ""
read -p "Please select a drive (sdX) > " drive_path
fi

sudo mkfs.ext4 /dev/mapper/$drive_name

}

function delete_cont() {
if [$containername = ''];
then
read -p "Enter container name > " containername
fi
close_cont
sudo rm /dev/mapper/$containername

}

function encrypt_drive() {

set_drive_variables
#create an encrypted partition
sudo cryptsetup luksFormat /dev/$drive_path
clear
echo "luksFormat complete"
sleep 2s

#unlock the partition
clear
echo "Unlocking partition..."
echo ""
sudo cryptsetup open /dev/$drive_path $drive_name
clear
echo "System unlocked"
sleep 3s

#format the drive
clear
echo "Formatting drive to ext4..."
sudo mkfs.ext4 /dev/mapper/$drive_name
echo "Format complete"
sleep 3s

#mount the partition
echo "Mounting at /mnt ..."
sudo mount /dev/mapper/$drive_name /mnt
echo "Mount complete"
sleep 3s
}

function open_drive() {
clear
set_drive_variables
clear
echo "Mounting at /mnt..."
sudo mount /dev/mapper/$drive_name /mnt
clear
echo "Decrypting Drive..."
sleep 1s
sudo cryptsetup open /dev/$drive_path $drive_name
echo ""
sleep 

}

function close_drive() {

set_drive_variables

sudo umount /mnt

sudo cryptsetup close $drive_name

#confirm drive is locked
sudo cryptsetup status $drive_name

}

function list_drives() {
sudo dmsetup ls --target crypt
}

home

