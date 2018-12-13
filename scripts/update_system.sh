#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Updating system"
yum install -y deltarpm yum-utils dracut-config-generic
yum -y update
