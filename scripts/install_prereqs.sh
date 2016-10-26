#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail


echo ">>> Kernel: $(uname -r)"
echo ">>> Updating system"
yum update --assumeyes

# so that the network interfaces are always eth0 not fancy new names
cat > /etc/default/grub <<EOF
GRUB_TIMEOUT=1
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="console=ttyS0,115200n8 console=tty0 net.ifnames=0 biosdevname=0 crashkernel=auto"
GRUB_DISABLE_RECOVERY="true"
EOF
grub2-mkconfig -o /boot/grub2/grub.cfg

echo ">>> Disabling SELinux"
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config

echo ">>> Adjusting SSH Daemon Configuration"

sed -i '/^\s*PermitRootLogin /d' /etc/ssh/sshd_config
echo -e "\nPermitRootLogin without-password" >> /etc/ssh/sshd_config

sed -i '/^\s*UseDNS /d' /etc/ssh/sshd_config
echo -e "\nUseDNS no" >> /etc/ssh/sshd_config

echo ">>> Disabling IPV6"
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

echo ">>> Installing DC/OS dependencies and essential packages"
yum install --assumeyes --tolerant perl tar xz unzip curl bind-utils net-tools ipset libtool-ltdl rsync

echo ">>> Installing things that Irving cares about"
yum install --assumeyes lvm2 xfsprogs ntp python-setuptools yum-utils git wget tuned sysstat iotop perf nc telnet
# enable NTP
systemctl enable ntpd

echo ">>> Installing AWS tools"
rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
/usr/bin/easy_install --script-dir /opt/aws/bin https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
for i in `/bin/ls -1 /opt/aws/bin/`; do ln -s /opt/aws/bin/$i /usr/bin/ ; done
yum install -y awscli atop
yum-config-manager --disable epel

echo ">>> Installing ChefDK"
curl -LO https://omnitruck.chef.io/install.sh && sudo bash ./install.sh -P chefdk && rm install.sh

echo ">>> Adding group [nogroup]"
/usr/sbin/groupadd -f nogroup

echo ">>> Cleaning up SSH host keys"
shred -u /etc/ssh/*_key /etc/ssh/*_key.pub

echo ">>> Cleaning up accounting files"
rm -f rm -f /var/run/utmp
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
