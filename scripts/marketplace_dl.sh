#!/bin/bash -x
set -o errexit -o nounset -o pipefail

VER_MARKETPLACE=5.1.0
VER_CHEFSERVER=13.1.8
VER_MANAGE=2.5.16
VER_PJS=3.0.3
VER_SUPERMARKET=3.3.7

DL_BASEURL="https://packages.chef.io/files"
DL_CHANNEL="stable"

mkdir -p /var/cache/marketplace
pushd /var/cache/marketplace

echo ">>> Writing out a timestamp"
echo "This package cache was generated for AWS Native Chef Stack marketplace ${VER_MARKETPLACE} on $(date)" > TIMESTAMP

echo ">>> Downloading and caching install scripts"
curl -s -OL https://aws-native-chef-server.s3.amazonaws.com/${VER_MARKETPLACE}/files/main.sh
chmod +x main.sh

echo ">>> Downloading and caching packages"
# Temporarily switch chef-server to current
#curl -s -OL ${DL_BASEURL}/${DL_CHANNEL}/chef-server/${VER_CHEFSERVER}/el/7/chef-server-core-${VER_CHEFSERVER}-1.el7.x86_64.rpm
curl -s -OL ${DL_BASEURL}/current/chef-server/${VER_CHEFSERVER}/el/7/chef-server-core-${VER_CHEFSERVER}-1.el7.x86_64.rpm
ln -s chef-server-core-${VER_CHEFSERVER}-1.el7.x86_64.rpm chef-server-core.rpm

curl -s -OL ${DL_BASEURL}/${DL_CHANNEL}/chef-manage/${VER_MANAGE}/el/7/chef-manage-${VER_MANAGE}-1.el7.x86_64.rpm
ln -s chef-manage-${VER_MANAGE}-1.el7.x86_64.rpm chef-manage.rpm

# temporary switch PJS to current
#curl -s -OL ${DL_BASEURL}/${DL_CHANNEL}/opscode-push-jobs-server/${VER_PJS}/el/7/opscode-push-jobs-server-${VER_PJS}-1.el7.x86_64.rpm
curl -s -OL ${DL_BASEURL}/current/opscode-push-jobs-server/${VER_PJS}/el/7/opscode-push-jobs-server-${VER_PJS}-1.el7.x86_64.rpm
ln -s opscode-push-jobs-server-${VER_PJS}-1.el7.x86_64.rpm push-jobs-server.rpm

curl -s -OL ${DL_BASEURL}/${DL_CHANNEL}/supermarket/${VER_SUPERMARKET}/el/7/supermarket-${VER_SUPERMARKET}-1.el7.x86_64.rpm
ln -s supermarket-${VER_SUPERMARKET}-1.el7.x86_64.rpm supermarket.rpm

curl -s https://packages.chef.io/files/current/automate/latest/chef-automate_linux_amd64.zip | gunzip - > chef-automate && chmod +x chef-automate
./chef-automate airgap bundle create chef-automate.bundle

echo ">>> Installing nightly snapshot script"
curl -s -L https://raw.githubusercontent.com/CaseyLabs/aws-ec2-ebs-automatic-snapshot-bash/master/ebs-snapshot.sh -o /usr/local/bin/ebs-snapshot.sh
chmod 755 /usr/local/bin/ebs-snapshot.sh

echo ">>> Installing aws-signing-proxy command"
curl -s -L https://github.com/chef-customers/aws-signing-proxy/releases/download/v0.5.0/aws-signing-proxy -o /usr/local/bin/aws-signing-proxy
chmod 755 /usr/local/bin/aws-signing-proxy

echo ">>> Installing other necessary packages"
yum install -y perl perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https perl-Digest-SHA zip unzip python-pip

echo ">>> Installing monitoring tools"
# Filebeat
curl -s -OL https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.6.6-x86_64.rpm

# awslogs
curl -s -OL https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py
chmod +x awslogs-agent-setup.py

popd

# Cloudwatch monitoring
mkdir -p /opt/cloudwatch_monitoring
pushd /opt/cloudwatch_monitoring
curl -s -OL http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip
unzip CloudWatchMonitoringScripts-1.2.1.zip
rm -f CloudWatchMonitoringScripts-1.2.1.zip
popd
