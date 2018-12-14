#!/bin/bash
set -o errexit -o nounset -o pipefail

### Procedure to create an image on an additional volume on an existing instance:
#
# - Launch a CentOS AMI, make sure it is a newer type that uses nvme disks (e.g. T3 or M5)
#   - At launch time, specify attaching a secondary volume that is 8GB.  Do not set the secondary volume to delete on termination.
# - Log in to your instance and become root (sudo -i)
# - Update your instance, especially if it is not the latest (< 7.6):  yum upgrade -y
# - run: curl -O https://raw.githubusercontent.com/irvingpop/packer-chef-highperf-centos7-ami/marketplace/create_base_ami.sh
# - Find the volume using "lsblk". It's probaly named "nvme1n1"
# - export DEVICE="/dev/nvme1n1" # export the DEVICE variable for this script
# - bash -x create_base_ami.sh # start this script
#
# Wait until the script has completed. Can can take 10 minutes or so.
#
# When complete, convert the $DEVICE into an AMI by creating a snapshot of the
# EBS volume and converting the snapshot into an AMI.  These steps can be done
# with the AWS web console or using the CLI tools.
#
# How to create an AMI of the volume?
#
# - Detach the additional volume from the instance in the EC2 Dashboard menu
#   Volumes.
# - Create a snapshot of the detached volume by selecting it, and executing the
#   action "Create Snapshot". Provide a useful description for the snapshot.
# - Create an AMI of the created snapshot in the EC2 Dashboard menu Snapshots
#   by selecting the snapshot and executing the action "Create Image". Provide
#   the following values:
#   - Name: Useful, short name.
#   - Description: Description, more verbose, including for example the script name and repo URL used to create it.
#   - Virtualisation type: Hardware-assisted vistualisation
#

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

# cat > "${ROOTFS}/etc/sysconfig/network-scripts/ifcfg-eth0" << END
# DEVICE="eth0"
# BOOTPROTO="dhcp"
# ONBOOT="yes"
# TYPE="Ethernet"
# USERCTL="yes"
# PEERDNS="yes"
# IPV6INIT="no"
# PERSISTENT_DHCLIENT="1"
# END

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
