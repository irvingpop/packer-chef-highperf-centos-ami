#!/bin/bash
set -o errexit -o nounset -o pipefail

yum upgrade -y

ROOTFS=/rootfs
DEVICE="/dev/nvme1n1"
PARTITION="${DEVICE}p1"

parted -s "$DEVICE" -- \
  mklabel msdos \
  mkpart primary xfs 1 -1 \
  set 1 boot on

# Wait for device partition creation which happens asynchronously
while [ ! -e "$PARTITION" ]; do sleep 1; done

mkfs.xfs -f -L root "$PARTITION"
mkdir -p "$ROOTFS"
mount "$PARTITION" "$ROOTFS"

rpm --root="$ROOTFS" --initdb
rpm --root="$ROOTFS" --nodeps -ivh \
  https://mirrors.edge.kernel.org/centos/7.6.1810/os/x86_64/Packages/centos-release-7-6.1810.2.el7.centos.x86_64.rpm
yum --installroot="$ROOTFS" --nogpgcheck -y update
yum --installroot="$ROOTFS" --nogpgcheck -y groupinstall "Minimal Install" \
  --exclude="iwl*firmware" \
  --exclude="NetworkManager*" \
  --exclude="alsa-*" \
  --exclude="aic94xx-firmware*" \
  --exclude=iprutils \
  --exclude=biosdevname \
  --exclude=ivtv-firmware \
  --exclude="plymouth*"
yum --installroot="$ROOTFS" -C -y remove firewalld --setopt="clean_requirements_on_remove=1"
yum --installroot="$ROOTFS" --nogpgcheck -y install grub2 chrony deltarpm yum-utils dracut-config-generic

cat > "${ROOTFS}/etc/hosts" << END
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
END

touch "${ROOTFS}/etc/resolv.conf"

cat > "${ROOTFS}/etc/sysconfig/network" << END
NETWORKING=yes
NOZEROCONF=yes
END

echo 'ZONE="UTC"' > "${ROOTFS}/etc/sysconfig/clock"

cat > "${ROOTFS}/etc/fstab" << END
LABEL=root / xfs defaults 0 0
END

echo 'RUN_FIRSTBOOT=NO' > "${ROOTFS}/etc/sysconfig/firstboot"

BINDMNTS="dev sys etc/hosts etc/resolv.conf"

for d in $BINDMNTS ; do
  mount --bind "/${d}" "${ROOTFS}/${d}"
done
mount -t proc none "${ROOTFS}/proc"

cat > "${ROOTFS}/etc/default/grub" << END
GRUB_TIMEOUT=1
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL="serial console"
GRUB_SERIAL_COMMAND="serial --speed=115200"
GRUB_CMDLINE_LINUX="console=tty0 crashkernel=auto console=ttyS0,115200"
GRUB_DISABLE_RECOVERY="true"
END

chroot "$ROOTFS" grub2-mkconfig -o /boot/grub2/grub.cfg
chroot "$ROOTFS" grub2-install "$DEVICE"
chroot "$ROOTFS" yum --nogpgcheck -y install cloud-init cloud-utils-growpart
chroot "$ROOTFS" systemctl enable sshd.service
chroot "$ROOTFS" systemctl enable cloud-init.service
chroot "$ROOTFS" systemctl enable chronyd.service
chroot "$ROOTFS" systemctl mask tmp.mount
chroot "$ROOTFS" systemctl set-default multi-user.target

# Because we're disabling NetworkManager, we encounter this
#   issue: https://bugs.centos.org/view.php?id=14760
#   where instances don't get an IPv6 default gateway.
#  I haven't figured out anything better yet than patching cloud-init in place
sed -i '/IPV6_AUTOCONF=.*/d' $ROOTFS/usr/lib/python2.7/site-packages/cloudinit/net/sysconfig.py

# borrowed from https://github.com/CentOS/sig-cloud-instance-build/blob/master/cloudimg/CentOS-7-x86_64-GenericCloud-201606-r1.ks
sed -i '/^#NAutoVTs=.*/ a\
NAutoVTs=0' $ROOTFS/etc/systemd/logind.conf

echo ">>> Disabling SELinux"
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' $ROOTFS/etc/selinux/config

cat > "${ROOTFS}/etc/cloud/cloud.cfg" << END
users:
 - default

disable_root: 1
ssh_pwauth:   0

locale_configfile: /etc/sysconfig/i18n
mount_default_fields: [~, ~, 'auto', 'defaults,nofail', '0', '2']
resize_rootfs_tmp: /dev
ssh_deletekeys:   0
ssh_genkeytypes:  ~
syslog_fix_perms: ~

cloud_init_modules:
 - migrator
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - rsyslog
 - users-groups
 - ssh

cloud_config_modules:
 - mounts
 - locale
 - set-passwords
 - yum-add-repo
 - package-update-upgrade-install
 - timezone
 - puppet
 - chef
 - salt-minion
 - mcollective
 - disable-ec2-metadata
 - runcmd

cloud_final_modules:
 - rightscale_userdata
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - phone-home
 - final-message

system_info:
  default_user:
    name: centos
    lock_passwd: true
    gecos: Cloud User
    groups: [wheel, adm, systemd-journal]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
  distro: rhel
  paths:
    cloud_dir: /var/lib/cloud
    templates_dir: /etc/cloud/templates
  ssh_svcname: sshd

# vim:syntax=yaml
END

umount -AR "$ROOTFS"
