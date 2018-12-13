#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Installing Docker"
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
# TODO: docker-compose is installed separately, make sure we track to the latest
#  via: https://docs.docker.com/compose/install/#install-compose
curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose
chmod a+x /usr/bin/docker-compose
systemctl enable docker.service

echo ">>> Adding group [nogroup]"
/usr/sbin/groupadd -f nogroup
