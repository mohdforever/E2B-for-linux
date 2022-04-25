
fmt.sh
======

This is a linux bash shell script which will install Easy2Boot onto a USB drive.
It will format an existing partition on the USB drive as FAT32 - it does not partition the USB drive.
If your USB drive is unformatted or has no partition table, 
you will need to make a new Active FAT32 Primary partition first using fdisk.

Note: if you get the error
./fmt.sh: 10: ./fmt.sh: [[: not found
then it is not running bash - try the command
sudo bash ./fmt.sh


fmt_ntfs.sh
===========

Similar to fmt.sh but formats the USB drive as NTFS.

To defrag an NTFS USB volume use udefrag (see below):
mount                                (check which device is USB drive - e.g. /media/user/XYZ as /dev/sdb1)
df                                   (list volumes)
sudo umount /dev/sdb1                (dismount the drive)
sudo ./udefrag -anm /dev/sdb1        (check state of partition
sudo ./udefrag -om /dev/sdb1         (defrag NTFS volume)


INSTRUCTIONS
============

WARNING: THIS SCRIPT IS DANGEROUS - IF YOU INPUT THE WRONG DEVICE NAME YOU COULD DESTROY A DIFFERENT PARTITION!

USE THIS SCRIPT AT YOUR OWN RISK!

1. Extract the Easy2Boot .ZIP file to your Documents folder on your linux system (must be on an ext2/3/4 volume)

2. Click on target USB drive icon - this mounts it and makes it easier to find

3. Find the \_ISO\docs\linux_utils folder

4. Right-click inside the \_ISO\docs\linux_utils folder and select Open In Terminal (or press CTRL+ALT+T)

5. This should open up a bash command shell at the linux_utils folder.

6. Now type these two commands

sudo chmod 777 *
sudo ./fmt.sh                 (or try     sudo bash ./fmt.sh   if you get errors)

make sure you input the correct device and partition name when prompted - e.g. /dev/sdc1  or /dev/sdd1 or /dev/sde1, etc. !!!!

To ensure the USB drive will boot on a wide variety of computers, ensure that the USB drive contains 2 PRIMARY PARTITIONS.
Some bad BIOSes need to see two primary partitions in order to boot the USB drive correctly as a 'hard disk'.

Defrag
======

To defrag FAT32 drive use defragfs, e.g. sudo ./defragfs /mnt/newusb -f

udefrag is a 32-bit linux utility for NTFS drives.
To run udefrag for NTFS drives under Ubuntu 64-bit:

sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386
(change to _ISO/docs/linux_utils folder)
sudo chmod 777 *
sudo udefrag -om /dev/sdX1  (where sdX1 is your NTFS USB partition)

Read more: https://easy2boot.xyz/create-your-website-with-blocks/make-using-linux/
