#!/bin/sh

USER=libvirt
HYPERVISOR=127.0.0.1
KSNAME=rhel7

CPU_CORES=2
# GBytes
DISK_SIZE=20
# MBytes
RAM_SIZE=2048

BRIDGE=

while [ "$1" != "${1##[-+]}" ]
do
	  case $1 in
	    '')
	           echo $"$0: Error:" $1
	           exit 1;;
	    --user)
		   USER=$2
		   shift 2
		   ;;
	    --user=?*)
	           USER=${1#--user=}
		   shift
		   ;;
	    --hypervisor)
		   HYPERVISOR=$2
		   shift 2
		   ;;
	    --hypervisor=?*)
		   HYPERVISOR=${1#--hypervisor=}
		   shift
		   ;;
	    --ksname)
		   KSNAME=$2
		   shift 2
		   ;;
	    --ksname=?*)
		   KSNAME=${1#--ksname=}
		   shift
		   ;;
	    --cpu-cores)
		   CPU_CORES=$2
		   shift 2
		   ;;
	    --cpu-cores=?*)
		   CPU_CORES=${1#--cpu-cores=}
		   shift
		   ;;
	    --disk-size)
		   DISK_SIZE=$2
		   shift 2
		   ;;
	    --disk-size=?*)
		   DISK_SIZE=${1#--disk-size=}
		   shift
		   ;;
	    --ram-size)
		   RAM_SIZE=$2
		   shift 2
		   ;;
	    --ram-size=?*)
		   RAM_SIZE=${1#--ram-size=}
		   shift
		   ;;
	    --bridge-extra)
		   BRIDGE=$2
		   shift 2
		   ;;
	    --bridge-extra=?*)
		   BRIDGE=${1#--bridge-extra=}
		   shift
		   ;;
	    *)
	           echo $"$0: Error:" $1
	           exit 1;;
	  esac
done

echo "USER: " ${USER}
echo "HYPERVISOR: " ${HYPERVISOR}
echo "KSNAME: " ${KSNAME}

echo "CPU: " ${CPU_CORES} "cores"
echo "DISK: " ${DISK_SIZE} "GBytes"
echo "MEMORY: " ${RAM_SIZE} "MBytes"
echo ${BRIDGE:+Extra bridge to connect\: ${BRIDGE}}

KSHOST=`ssh ${USER}@${HYPERVISOR} avahi-resolve-host-name -4 kickstart.local|cut -f 2 | tr -d '\n'`
VIRTNAME=$KSNAME-`date +%Y-%m-%d-%H-%M`

virt-install --connect=qemu+ssh://${USER}@${HYPERVISOR}/system \
	--network=bridge:virbr0 \
	${BRIDGE:+\-\-network\=bridge\:${BRIDGE}} \
	--location=http://mirror.yandex.ru/centos/7/os/x86_64/ \
	--extra-args="ks=http://${KSHOST}:8080/${KSNAME} ip=dhcp console=tty0 console=ttyS0,115200 ksdevice=eth0" \
	--name=${VIRTNAME} \
	--disk /var/lib/libvirt/images/${VIRTNAME}.img,size=${DISK_SIZE} \
	--ram ${RAM_SIZE} \
	--vcpus=${CPU_CORES} \
	--check-cpu \
	--accelerate \
	--hvm \
	--nographics \
	--noreboot
