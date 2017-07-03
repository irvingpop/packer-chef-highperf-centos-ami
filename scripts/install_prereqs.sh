#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail


echo ">>> Kernel: $(uname -r)"
echo ">>> Updating system"
yum -y update

# so that the network interfaces are always eth0 not fancy new names
echo ">>> Updating GRUB settings"
cat > /etc/default/grub <<EOF
GRUB_TIMEOUT=1
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="console=ttyS0,115200n8 console=tty0 net.ifnames=0 biosdevname=0 crashkernel=auto scsi_mod.use_blk_mq=Y transparent_hugepage=never"
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

echo ">>> Setting system performance tunings"
cat > /etc/sysctl.d/chef-highperf.conf <<EOF
vm.swappiness=10
vm.max_map_count=256000
vm.dirty_ratio=20
vm.dirty_background_ratio=30
vm.dirty_expire_centisecs=30000
EOF

echo ">>> Installing OS dependencies and essential packages"
yum -y install --tolerant perl tar xz unzip curl bind-utils net-tools ipset libtool-ltdl rsync

echo ">>> Installing things that Irving cares about"
yum -y install lvm2 xfsprogs ntp python-setuptools yum-utils git wget tuned sysstat iotop perf nc telnet vim
# enable NTP
systemctl enable ntpd

echo ">>> Installing AWS tools"
/usr/bin/easy_install --script-dir /opt/aws/bin https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
for i in `/bin/ls -1 /opt/aws/bin/`; do ln -s /opt/aws/bin/$i /usr/bin/ ; done
rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y awscli atop dkms
yum-config-manager --disable epel

echo ">>> Building Amazon ENA driver"
git clone https://github.com/amzn/amzn-drivers /usr/src/amzn-drivers-1.0.0
cd /usr/src/amzn-drivers-1.0.0

cat > dkms.conf <<EOF
PACKAGE_NAME="ena"
PACKAGE_VERSION="1.0.0"
CLEAN="make -C kernel/linux/ena clean"
MAKE="make -C kernel/linux/ena/ BUILD_KERNEL=\${kernelver}"
BUILT_MODULE_NAME[0]="ena"
BUILT_MODULE_LOCATION="kernel/linux/ena"
DEST_MODULE_LOCATION[0]="/updates"
DEST_MODULE_NAME[0]="ena"
AUTOINSTALL="yes"
EOF

yum install -y kernel-headers kernel-devel make
latest_kernel=`/bin/ls -1tr /boot/initramfs-* | sed -e 's/\/boot\/initramfs-//' -e 's/.img//' | tail -1`
dkms add -m amzn-drivers -v 1.0.0
dkms build -m amzn-drivers -v 1.0.0 -k $latest_kernel
dkms install -m amzn-drivers -v 1.0.0 -k $latest_kernel
cd

echo ">>> Installing ChefDK"
curl -LO https://omnitruck.chef.io/install.sh && sudo bash ./install.sh -P chefdk && rm install.sh

echo ">>> Adding group [nogroup]"
/usr/sbin/groupadd -f nogroup

# Pull in latest improvements from DCOS image repo
# TODO research:  I'm pretty sure these have no impact on a chef server because we have our own logging facility
echo ">>> Disable rsyslog"
systemctl disable rsyslog

echo ">>> Set journald limits"
mkdir -p /etc/systemd/journald.conf.d/
echo -e "[Journal]\nRateLimitBurst=15000\nRateLimitInterval=30s\nSystemMaxUse=10G" > /etc/systemd/journald.conf.d/dcos-el7.conf

echo ">>> Removing tty requirement for sudo"
sed -i'' -E 's/^(Defaults.*requiretty)/#\1/' /etc/sudoers

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
