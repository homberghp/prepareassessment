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
	if [[ $vm =~ ^'SanDisk Extreme'.* ]] ; then 
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
    local sizeid=$((512*${size}/(1000*1000*1000)))
    local parttablefile=${scriptdir}/part-16GB
    echo using ${sizeid} partition on device ${disk}
    echo \# zapping ${disk} size ${sizeid}
    sgdisk  --zap-all /dev/${disk} 2&>/dev/null
    echo done zapping
    sync
    sleep 1
    parttablefile=${scriptdir}/part-${sizeid}GB
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
    local size=$(cat /sys/block/$disk/size)
    local sizeid=$((512*${size}/(1000*1000*1000)))
    echo "disk ${disk} size ${sizeid}"
    local bootblokfile=${scriptdir}/bootblk-${sizeid}GB.bin-new
    ${debug} dd conv=fsync if=${bootblokfile} bs=1M of=/dev/${disk}
    sleep 1
    partprobe /dev/${disk}
}

dev2Label(){
    local d=$1
    if [[ ${#d} > 8 ]]; then  
	d=${d:0:8}
    fi
    echo disk $d
    local label=$(blkid ${d}1)
    label=${label:18:7}
    echo -n $label
}

# partition and make file system
# @param $1 disk like sdc or sdd
# @param $2 disk label like EXAM123
prepareStick() {
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

##
# Clean the work partitions.
# After multiple exams the casper-rw file system (which is in a file) 
# could have filled up or be corrupted. Casper-rw contains /var which in turn contains
# the log files, many dynamic settings and the data persistens stuff of the database (postgres)
# When the file system appears empty, the init sequence of linux should reinitialize it on first boot.
# Pre
# @param disk label like EXAM123
cleanCasperRW(){
    local LABEL=$1
    local MOUNTPOINT=/media/usb/${LABEL}
    echo creating casper-rw file space for stick ${LABEL}
    ${debug} dd if=/dev/zero of=${MOUNTPOINT}/casper-rw bs=1M count=1536
    echo initializing casper-rw file-system for stick ${LABEL}
    mkfs.ext2 -q -F ${MOUNTPOINT}/casper-rw
}

fastCleanCasperRW(){
    local LABEL=$1
    local MOUNTPOINT=/media/usb/${LABEL}
    # echo creating casper-rw file space for stick ${LABEL}
    # ${debug} dd if=/dev/zero of=${MOUNTPOINT}/casper-rw bs=1M count=1536
    
    echo initializing casper-rw file-system for stick ${LABEL}
    umount /media/usb/casper-rw-${LABEL}
    
    mkfs.ext2 -q -F ${MOUNTPOINT}/casper-rw
}

checkHomeRW(){
    local d=$1
    echo checking fs on ${d}
    fsck.ext2 -fp ${d} || echo -e "\033[31;1mpersistent errors on $(dev2Label $d)\033[m"
}

createHomeRW(){
    local d=$1
    echo creating fs on ${d}
    ${debug} mkfs.ext2 -q -L home-rw /dev/${d}2
}
freshHomeRW(){
    local d=$1
    echo creating fs on ${d}
    ${debug} mkfs.ext2 -q -L home-rw ${d}
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
    cleanCasperRW ${LABEL} 
    echo  start copy of ISO files to stick ${LABEL} using image from ${IMAGE_DIR}
    ${debug} cp -r ${IMAGE_DIR}/ISO/{boot,casper,.disk,dists,EFI,install,md5sum.txt,pics,pool,preseed,README.diskdefines} ${MOUNTPOINT}
    ${debug} cp -r ${IMAGE_DIR}/ISO/isolinux ${MOUNTPOINT}/syslinux
    echo  "copy syslinux.cfg for stick ${LABEL}"
    ${debug} cp -r ${IMAGE_DIR}/ISO/isolinux/isolinux.cfg ${MOUNTPOINT}/syslinux/syslinux.cfg
#    ${debug} mv ${MOUNTPOINT}/syslinux/{iso,sys}linux.cfg
#    ${debug} syslinux --install /dev/${d}1
    ${debug} syslinux --stupid ${BOOTPART}
    echo installation for stick ${LABEL} done
    if [ -e skel.tgz ] ; then
	rm -fr  ${HOMEMOUNTPOINT}/*
	if [[ ${LABEL:0:4} = 'EXAM' ]] ; then
	    mkdir -p  ${HOMEMOUNTPOINT}/exam
	    tar -C ${HOMEMOUNTPOINT}/exam -xzf skel.tgz
	    chown -R exam:exam ${HOMEMOUNTPOINT}/exam
	else
	    mkdir -p  ${HOMEMOUNTPOINT}/sebi
	    tar -C ${HOMEMOUNTPOINT}/sebi -xzf skel.tgz
	    chown -R 1002:1002 ${HOMEMOUNTPOINT}/sebi
	fi
    fi
    umount ${BOOTPART} ${HOMEPART}
    echo installation for stick ${LABEL} done
}
