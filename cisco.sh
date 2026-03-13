#!/bin/bash
exec qemu-system-x86_64 \
	-name "CiscoPacketTracer" \
	-enable-kvm \
        -cpu host \
	-m 9G \
        -smp 5 \
	-drive file=./qemu/CiscoPacketTracer,format=qcow2 \
        -nic bridge,br=br0,model=virtio-net-pci,mac=52:54:01:12:34:87 \
	-vga qxl \
	-spice port=5090,disable-ticketing=on,gl=on \
	-display spice-app \
	-device virtio-serial-pci \
    	-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
    	-chardev spicevmc,id=spicechannel0,name=vdagent \
	-virtfs local,path=./pt,mount_tag=hostshare,security_model=none,id=hostshare \
        $@
