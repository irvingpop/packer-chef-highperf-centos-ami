#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Updating system"
yum install -y deltarpm yum-utils dracut-config-generic
yum -y update

# so that the network interfaces are always eth0 not fancy new names
echo ">>> Updating GRUB settings"
cat > /etc/default/grub <<EOF
GRUB_TIMEOUT=1
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="console=ttyS0,115200n8 console=tty0 crashkernel=auto scsi_mod.use_blk_mq=Y dm_mod.use_blk_mq=y transparent_hugepage=never"
GRUB_DISABLE_RECOVERY="true"
EOF
grub2-mkconfig -o /boot/grub2/grub.cfg

echo ">>> Compatibility fixes for newer AWS instances like C5 and M5"
# per https://bugs.centos.org/view.php?id=14107&nbn=5
latest_kernel=$(/bin/ls -1t /boot/initramfs-* | sort | grep -v kdump | sed -e 's/\/boot\/initramfs-//' -e 's/.img//' | tail -1)
echo "Updating the initramfs file for newly installed kernel ${latest_kernel}"
dracut -f --kver $latest_kernel

echo ">>> Installing Chef Workstation (includes ChefDK)"
curl -LO https://omnitruck.chef.io/install.sh && sudo bash ./install.sh -P chef-workstation && rm install.sh

echo ">>> Cleaning up SSH host keys"
shred -u /etc/ssh/*_key /etc/ssh/*_key.pub

echo ">>> Cleaning up accounting files"
rm -f /var/run/utmp
>/var/log/lastlog
>/var/log/wtmp
>/var/log/btmp

echo ">>> Remove temporary files"
rm -rf /tmp/* /var/tmp/*

echo ">>> Remove ssh client directories"
rm -rf /home/*/.ssh /root/.ssh

echo ">>> Remove history"
unset HISTFILE
rm -rf /home/*/.*history /root/.*history

# Make sure we wait until all the data is written to disk, otherwise
# Packer might quite too early before the large files are deleted
sync
