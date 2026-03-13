#!/bin/bash
exec qemu-system-x86_64 \
	## general config:
	-name "CiscoPacketTracer" \
	-enable-kvm \
        -cpu host \
	-m 9G \
        -smp 5 \
	-drive file=./qemu/CiscoPacketTracer,format=qcow2 \
	## connect to my local network thru a bridge:
        -nic bridge,br=br0,model=virtio-net-pci,mac=52:54:01:12:34:87 \
	## improve gui performance
	-vga qxl \
	# cinfigure scpice access
	-spice port=5090,disable-ticketing=on,gl=on \
	-display spice-app \
	# enable copy pasta and better gui
	-device virtio-serial-pci \
    	-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
    	-chardev spicevmc,id=spicechannel0,name=vdagent \
	# share the pt directory with the host to persist PacketTraser configs
	-virtfs local,path=/home/pk/qemu_packer_builder/pt,mount_tag=hostshare,security_model=none,id=hostshare \
        $@
