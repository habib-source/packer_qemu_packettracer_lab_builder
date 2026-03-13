source "qemu" "example" {
  iso_url           = "https://cdimage.debian.org/debian-cd/13.3.0-live/amd64/iso-hybrid/debian-live-13.3.0-amd64-standard.iso"
  iso_checksum      = "ee2b3d5f9bc67d801eefeddbd5698efbb0b35358724b7ed3db461be3f5e7ecd6"
  output_directory  = "qemu"
  headless          = true
  shutdown_command  = "echo 'cisco' | sudo -S shutdown -P now"
  disk_size         = "50000M"
  cpus              = 2
  memory            = 2000
  format            = "qcow2"
  accelerator       = "kvm"
  http_directory    = "http"
  ssh_username      = "root"
  ssh_password      = "cisco"
  ssh_timeout       = "200m"
  communicator      = "ssh"
  vm_name           = "CiscoPacketTracer"
  net_device        = "virtio-net"
  disk_interface    = "virtio"
  boot_wait         = "10s"
  boot_command      = [
    "<esc><wait>",
    "/install/vmlinuz<wait>",
    " initrd=/install/initrd.gz",
    " auto-install/enable=true",
    " debconf/priority=critical",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<wait>",
    " -- <wait>",
    "<enter><wait>"
  ]
}

build {
  name = "CiscoPacketTracer"
  sources = ["source.qemu.example"]

  provisioner "file" {
    source = "CiscoPacketTracer_900_Ubuntu_64bit.deb"
    destination = "/tmp/CiscoPacketTracer.deb"
  }

  provisioner "shell" {
    inline = [<<-EOF
      DEBIAN_FRONTEND=noninteractive
      apt-get install -y libfuse2 libpulse0 fuse libpcre2-dev xdg-utils spice-vdagent xorg openbox surf neovim
      yes 2 | dpkg -i /tmp/CiscoPacketTracer.deb
      apt-get install -fy
      echo 'if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then exec startx; fi' >>  /home/cisco/.bash_profile
      echo 'BROWSER="firefox"' >>  /home/cisco/.bash_profile
      echo 'spice-vdagent &\nexec openbox-session' >> /home/cisco/.xinitrc
      echo "hostshare  /home/cisco/pt  9p  trans=virtio,version=9p2000.L,rw,user,_netdev  0  0" >> /etc/fstab
      EOF
    ]
  }
}
