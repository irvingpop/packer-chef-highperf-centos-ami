#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Disabling SELinux"
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
setenforce 0
