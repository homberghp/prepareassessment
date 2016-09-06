#!/bin/bash
# this a collection of helper scripts
scriptdir=$(dirname $(readlink -f $0))
scriptdir=/home/prepareassessment/bin

function enumerateSticks(){
    local disks=''
    for d in $(ls -d /sys/block/sd?  | grep -P '\/sys\/block\/sd[c-z]'  ) ; do
	# only accept sandisk extreme
	v=$(cat $d/device/vendor); v=${v// /} # trim spaces
	m=$(cat $d/device/model); m=${m// /} # trim spaces
	vm="$v $m"
	if [[ $vm == 'SanDisk Extreme' ]] ; then 
#	    echo "'${vm}'"
	    disk=$(basename $d)
	    if [[ ${disks}a == a ]]; then disks="$disk"; else disks="$disks,$disk"; fi
	fi
    done
    echo "$disks"
}

# partition a stick using zap and sfdisk
# @param disk id such as sdc 
partitionStick(){
    local parttablefile=${scriptdir}/part-16GB
    disk=$1
    local size=$(cat /sys/block/$disk/size)
    size=$((512*${size}))
    sizeid=${size:0:2}GB
    local parttablefile=${scriptdir}/part-16GB
    echo using ${sizeid} partition on device ${disk}
    echo \# zapping ${disk} size ${sizeid}
    sgdisk  --zap-all /dev/${disk} 2&>/dev/null
    echo done zapping
    sync
    sleep 1
    parttablefile=${scriptdir}/part-${sizeid}
    echo using part table ${parttablefile}
    cat ${parttablefile} | sfdisk -q --force /dev/${disk} # 2&>> sfdisk.log
    sync
    sleep 1
    partprobe /dev/$disk
    fdisk -l /dev/${disk}
}

# partition a stick using dd
# @param disk id such as sdc 
partitionStickalt(){
    disk=$1
    size=$(cat /sys/block/$disk/size)
    size=$((512*${size}))
    sizeid=${size:0:2}GB
    local bootblokfile=${scriptdir}/bootblk-${sizeid}.bin-new
    ${debug} dd conv=fsync if=${bootblokfile} bs=1M of=/dev/${disk}
    sleep 1
    partprobe /dev/${disk}
}

# partition and make file system
# @param $1 disk like sdc or sdd
# @param $2 disk label like EXAM123
prepapeStick() {
    local d=$1
    local LABEL=$2
    ${debug} partitionStickalt ${d}
    echo creating vfat file system on /dev/${d}1
    ${debug} mkfs.vfat -n ${LABEL} /dev/${d}1
    echo done creating vfat file system on /dev/${d}1
    echo creating ext2 file system on /dev/${d}2
    ${debug} mkfs.ext2 -q -L home-rw /dev/${d}2
    echo done creating ext2 file system on /dev/${d}2
}

# label partitions 
# @param $1 disk like sdc or sdd
# @param $2 disk label like EXAM123
labelParts(){
    local d=$1
    local LABEL=$2
    mlabel -i /dev/${d}1 ::${LABEL} 
    e2label /dev/${d}2 home-rw
}
# install a linux live exam environment 
# @param $1 disk like sdc or sdd
# @param $2 disk label like EXAM123
installToStick() {
    local d=$1
    local LABEL=$2
    local MOUNTPOINT=/media/usb/${LABEL}
    local HOMEMOUNTPOINT=/media/usb/home-rw-${LABEL}
    local BOOTPART=/dev/${d}1
    local HOMEPART=/dev/${d}2
    ${debug} mkdir -p ${MOUNTPOINT} ${HOMEMOUNTPOINT}
    # mount partition 1
    ${debug} mount ${BOOTPART}  ${MOUNTPOINT}
    ${debug} mount ${HOMEPART}  ${HOMEMOUNTPOINT}
    echo  start copy of ISO files to stick ${LABEL}
    ${debug} cp -r /home/U14.04/ISO/{boot,casper,.disk,dists,EFI,install,md5sum.txt,pics,pool,preseed,README.diskdefines} ${MOUNTPOINT}
    ${debug} cp -r /home/U14.04/ISO/isolinux ${MOUNTPOINT}/syslinux
    echo  rename syslinux.cfg for stick ${LABEL}
    ${debug} mv ${MOUNTPOINT}/syslinux/{iso,sys}linux.cfg
    echo creating casper-rw file space for stick ${LABEL}
    ${debug} dd if=/dev/zero of=${MOUNTPOINT}/casper-rw bs=1M count=1024
    echo initializing casper-rw file-system for stick ${LABEL}
    mkfs.ext4 -q -F ${MOUNTPOINT}/casper-rw
#    ${debug} syslinux --install /dev/${d}1
    ${debug} syslinux --stupid ${BOOTPART}
    echo installation for stick ${LABEL} done
    if [ -e skel.tgz ] ; then
	rm -fr  ${HOMEMOUNTPOINT}/{exam,sebi}
	mkdir -p  ${HOMEMOUNTPOINT}/{exam,sebi}
	tar -C ${HOMEMOUNTPOINT}/sebi -xzf skel.tgz
	chown -R sebi:sebi ${HOMEMOUNTPOINT}/sebi
	tar -C ${HOMEMOUNTPOINT}/exam -xzf skel.tgz
	chown -R exam:exam ${HOMEMOUNTPOINT}/exam
    fi
    umount ${BOOTPART} ${HOMEPART}
}
