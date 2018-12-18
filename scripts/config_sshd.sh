#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Adjusting SSH Daemon Configuration"
sed -i '/^\s*PermitRootLogin /d' /etc/ssh/sshd_config
echo -e "\nPermitRootLogin without-password" >> /etc/ssh/sshd_config

sed -i '/^\s*UseDNS /d' /etc/ssh/sshd_config
echo -e "\nUseDNS no" >> /etc/ssh/sshd_config
