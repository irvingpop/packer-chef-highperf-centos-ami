#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Compatibility fixes for newer AWS instances like C5 and M5"
# per https://bugs.centos.org/view.php?id=14107&nbn=5
latest_kernel=$(/bin/ls -1t /boot/initramfs-* | sort | grep -v kdump | sed -e 's/\/boot\/initramfs-//' -e 's/.img//' | tail -1)
echo "Updating the initramfs file for newly installed kernel ${latest_kernel}"
dracut -f --kver $latest_kernel

echo ">>> Fixing issue with net device eth0 being expected"
rm -f /etc/sysconfig/network-scripts/ifcfg-eth0
