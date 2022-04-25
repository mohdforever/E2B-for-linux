#!/bin/bash
# Bash Script for formatting USB drives by GNUger and SSi

clear

echo "WARNING: THIS BASH SCRIPT CAN FORMAT THE WRONG DRIVE IF USED INCORRECTLY!"
echo "USE AT YOUR OWN RISK"
echo

if [[ $EUID -ne "0" ]]
then
 echo "You must be root - try:   sudo $0 or sudo bash $0"
exit 1
fi

script="$0"
basename="$(dirname $script)"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "$script resides in directory $DIR"

echo "Looking for _ISO/e2b folder - please wait..."

COUNTER=0

if [ -e "$DIR/../../../_ISO/e2b" ]
then
  let COUNTER=20
SRC="$DIR/../../../"
echo Found SOURCE at $SRC
echo ""
ls $SRC
fi

echo ""
echo "THIS SCRIPT REQUIRES THE BASH SHELL - e.g. sudo bash $0"
echo ""

 while [  $COUNTER -lt 10 ]; do
 echo "Looking for e2b.ico file under / - please wait..."
 find / -name 'e2b.ico' 2>/dev/null 
 echo ""
 echo "Example: /home/mint/Documents/E2B"
 echo ""
 read -p  "Enter source folder for E2B files : " SRC

 echo ""
 echo "Source folder is $SRC"
 ls $SRC
 echo ""

if [ -e "$SRC/_ISO" ]
then
  let COUNTER=20
fi

if [ $COUNTER -lt 10 ]
then
echo ""
echo "ERROR: No _ISO folder!"
read -p "Is this folder correct (y/n) : " opinion2

if [[ $opinion2 == 'y' ]] || [[ $opinion2 == 'yes' ]]
 then
   let COUNTER=COUNTER+20
 else
   clear
 fi

fi
done




echo ""
df | grep '/dev/sd'
echo ""

device=$(df | grep '/dev/sd' | tail -n1 | awk '{ print $1; }')
read -p "Is target device ($device) correct (y/n) : " opinion1
if [[ $opinion1 == 'n' ]] || [[ $opinion1 == 'no' ]]
then
 read -p "Enter partition name (e.g. /dev/sdc1 ) : " device
 fi
echo

DD="${device:0:8}"
if [ "$DD" == "/dev/sda" ];
then
echo "WARNING: $device may be your internal hard disk!"
fi

DD="${device:0:7}"
if [ "$DD" == "/dev/sd" ];
then
echo ""
else
echo "Bad device - must start with /dev/sd"
exit 1
fi

if [ ${device:8:1} -lt 3 ]
then
echo Partition = ${device:8:1}
else
echo "Bad Partition! should end in the number 1 or 2 - e.g. /dev/sdc1"
exit 1
fi

if [ ${device:8:1} == 0 ]
then
echo "Bad Partition! should end in the number 1 or 2 - e.g. /dev/sdc1"
exit1
fi

echo "Formatting: $device"
echo
read -p "Proceed with formatting (y/n): " opinion2
if [[ $opinion2 == 'y' ]] || [[ $opinion2 == 'yes' ]]

then

# This wipes the drive but then mkfs.vfat creates a superfloppy and bootlace fails - use fdisk manually to wipe a USB drive!
#read -p "Do you want to erase all partitions on ${device:0:-1} first (y/n) : " opinion2
#if [[ $opinion2 == 'y' ]] || [[ $opinion2 == 'yes' ]]
#then
#  dd if=/dev/zero of=${device:0:-1}  bs=512  count=1
#fi

 sudo umount $device  2>/dev/null
 sudo umount /mnt/myusb  2>/dev/null
 label="EASY2BOOT"
 /sbin/mkfs.vfat -F32 -n "$label" $device
 ptn=${device: -1}
 echo Making partition "$ptn" active using parted...
 sudo parted -s ${device%?} set $ptn boot on
sleep 2
sync
sleep 5
 
 echo Mounting $device as /mnt/myusb
 sudo mkdir /mnt 2>/dev/null
 sudo mkdir /mnt/myusb 2>/dev/null
 sudo mount $device /mnt/myusb


 echo Installing grub4dos to MBR
 sudo chmod +rwx $DIR/bootlace.com
 sudo $DIR/bootlace.com --time-out=0 ${device%?}
 echo Installing grub4dos to PBR
 sudo $DIR/bootlace.com --floppy=1 $device

 echo Copying $SRC to /mnt/myusb...
 cp -r -i  $SRC /mnt/myusb

 echo ""
 echo "Easy2Boot USB Drive contents..."
 ls /mnt/myusb/
echo ""
echo "Please wait - flushing write cache and unmounting drive..."
# commit writes when it unmounts before user pulls it out!
sudo umount /mnt/myusb
echo ""
echo "If this fails, you may need to use fdisk to delete the drive contents"
echo "See www.rmprepusb.com - Tutorial 114 for details"
echo ""
sudo fdisk -l ${device%?}
echo ""
echo "Note: For best boot compatibilty, ensure a second Primary partition exists on the E2B USB drive."
echo "The second partition can be very small and does not need to be formatted."
echo ""
echo "Use 'sudo perl ~/Downloads/Easy2Boot/_ISO/docs/linux_utils/defragfs /media/Multiboot -f' to defrag this volume."
exit 1

fi
