#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Installing OS dependencies and essential packages"
yum -y install --tolerant perl tar xz unzip curl bind-utils net-tools ipset libtool-ltdl rsync
