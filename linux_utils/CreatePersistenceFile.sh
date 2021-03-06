#!/bin/sh

size=1024
fstype=ext4
label=casper-rw
config=''

print_usage() {
    echo 'Usage:  CreatePersistenceFile.sh [ -s size ] [ -t fstype ] [ -l LABEL ] [ -c CFG ]'
	echo 'Creates new file named persistence.dat'
	echo ''
    echo '  OPTIONS: (optional)'
    echo '   -s size, in MB, default is 1024'
    echo '   -t filesystem_type, default is ext4,  ext2/ext3/ext4/xfs are supported'
    echo '   -l label, default is casper-rw'
    echo '   -c configfile, creates new file inside the persistence file. File content is "/ union"'
	echo ''
    echo 'EXAMPLE:  sh CreatePersistenceFile.sh -l persistence -c persistence.conf'
    echo 'EXAMPLE:  sh CreatePersistenceFile.sh -s 2048 -t ext3 -l casper-rw'
	echo ''
}

while [ -n "$1" ]; do
    if [ "$1" = "-s" ]; then
        shift
        size=$1
    elif [ "$1" = "-t" ]; then
        shift
        fstype=$1
    elif [ "$1" = "-l" ]; then
        shift
        label=$1
    elif [ "$1" = "-c" ]; then
        shift
        config=$1
    elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        print_usage
        exit 0
    else
        print_usage
        exit 1
    fi
    shift
done


# check label
if [ -z "$label" ]; then
    echo "The label can NOT be empty."
    exit 1
fi

# check size
if echo $size | grep -q "^[0-9][0-9]*$"; then
    if [ $size -le 1 ]; then
        echo "Invalid size $size"
        exit 1
    fi
else
    echo "Invalid size $size"
    exit 1
fi


# check file system type
# nodiscard must be set for ext2/3/4
# -K must be set for xfs 
if echo $fstype | grep -q '^ext[234]$'; then
    fsopt='-E nodiscard'
elif [ "$fstype" = "xfs" ]; then
    fsopt='-K'
else
    echo "unsupported file system $fstype"
    exit 1
fi

# 00->ff avoid sparse file
dd if=/dev/zero  bs=1M count=$size | tr '\000' '\377' > persistence.dat
sync

freeloop=$(losetup -f)

losetup $freeloop persistence.dat

mkfs -t $fstype $fsopt -L $label $freeloop 

sync

if [ -n "$config" ]; then
    if [ -d ./persist_tmp_mnt ]; then
        rm -rf ./persist_tmp_mnt
    fi
    
    mkdir ./persist_tmp_mnt
    if mount $freeloop ./persist_tmp_mnt; then
        echo '/ union' > ./persist_tmp_mnt/$config
        sync
        umount ./persist_tmp_mnt
    fi
    rm -rf ./persist_tmp_mnt
fi

losetup -d $freeloop
