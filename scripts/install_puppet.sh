#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Installing Puppet client"
if yum repolist | grep -q ^puppet6
then
    echo ">>>> puppet6 repository is already installed"
else
    yum install -y https://yum.puppetlabs.com/puppet6/puppet6-release-el-7.noarch.rpm
fi
yum install -y puppet
# puppet is not enabled, because not everyone may like that
