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

echo ">>> Disabling SELinux"
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
setenforce 0

echo ">>> Adjusting SSH Daemon Configuration"
sed -i '/^\s*PermitRootLogin /d' /etc/ssh/sshd_config
echo -e "\nPermitRootLogin without-password" >> /etc/ssh/sshd_config

sed -i '/^\s*UseDNS /d' /etc/ssh/sshd_config
echo -e "\nUseDNS no" >> /etc/ssh/sshd_config

echo ">>> Setting system performance tunings"
cat > /etc/sysctl.d/00-chef-highperf.conf <<EOF
vm.swappiness=10
vm.max_map_count=262144
vm.dirty_ratio=20
vm.dirty_background_ratio=30
vm.dirty_expire_centisecs=30000
EOF

cat > /etc/security/limits.d/20-nproc.conf<<EOF
*   soft  nproc     65536
*   hard  nproc     65536
*   soft  nofile    1048576
*   hard  nofile    1048576
EOF

echo ">>> Installing OS dependencies and essential packages"
yum -y install --tolerant perl tar xz unzip curl bind-utils net-tools ipset libtool-ltdl rsync

echo ">>> Installing things that Irving cares about"
yum -y install lvm2 xfsprogs python-setuptools yum-utils git wget tuned sysstat iotop perf nc telnet vim awscli bash-completion
# fix bug in awscli: https://bugzilla.redhat.com/show_bug.cgi?id=1578083 - 2018/07/02
cat /usr/lib/python2.7/site-packages/awscli/customizations/s3/transferconfig.py | grep -v -F -x "    'max_bandwidth': None" > /tmp/transferconfig.py && mv /tmp/transferconfig.py /usr/lib/python2.7/site-packages/awscli/customizations/s3/transferconfig.py
# enable chronyd (better than NTP)
systemctl enable chronyd.service

echo ">>> Installing AWS tools and EPEL-based sysadmin tools"
/usr/bin/easy_install --script-dir /opt/aws/bin https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
for i in `/bin/ls -1 /opt/aws/bin/`; do ln -s /opt/aws/bin/$i /usr/bin/ ; done
rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y atop bash-completion-extras

echo ">>> Compatibility fixes for newer AWS instances like C5 and M5"
# per https://bugs.centos.org/view.php?id=14107&nbn=5
latest_kernel=$(/bin/ls -1t /boot/initramfs-* | sort | grep -v kdump | sed -e 's/\/boot\/initramfs-//' -e 's/.img//' | tail -1)
echo "Updating the initramfs file for newly installed kernel ${latest_kernel}"
dracut -f --kver $latest_kernel

echo ">>> Installing ChefDK"
curl -LO https://omnitruck.chef.io/install.sh && sudo bash ./install.sh -P chef-workstation && rm install.sh

echo ">>> Installing Docker"
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
# TODO: docker-compose is installed separately, make sure we track to the latest
#  via: https://docs.docker.com/compose/install/#install-compose
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose
chmod a+x /usr/bin/docker-compose
systemctl enable docker.service

echo ">>> Adding group [nogroup]"
/usr/sbin/groupadd -f nogroup

echo ">>> Disable rsyslog and kdump"
systemctl disable rsyslog.service kdump.service

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
