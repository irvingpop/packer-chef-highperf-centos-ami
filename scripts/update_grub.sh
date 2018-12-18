#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

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
