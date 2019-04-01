#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

# No longer needed, wasn't working anyway.  Remove after 6 months - Irving 2019/04/01
# echo ">>> Compatibility fixes for newer AWS instances like C5 and M5"
# # per https://bugs.centos.org/view.php?id=14107&nbn=5
# latest_kernel=$(/bin/ls -1t /boot/initramfs-* | sort | grep -v kdump | sed -e 's/\/boot\/initramfs-//' -e 's/.img//' | tail -1)
# echo "Updating the initramfs file for newly installed kernel ${latest_kernel}"
# dracut -f --kver $latest_kernel

echo ">>> Fixing issue with net device eth0 being expected"
rm -f /etc/sysconfig/network-scripts/ifcfg-eth0

# Because we're disabling NetworkManager, we encounter this
#   issue: https://bugs.centos.org/view.php?id=14760
#   where instances don't get an IPv6 default gateway.
#  I haven't figured out anything better yet than patching cloud-init in place
echo ">>> Fixing issue with IPv6 default gateway not appearing"
sed -i '/IPV6_AUTOCONF=.*/d' /usr/lib/python2.7/site-packages/cloudinit/net/sysconfig.py
