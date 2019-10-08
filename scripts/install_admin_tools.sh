#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Installing things that Irving cares about"
yum -y install lvm2 xfsprogs python-setuptools yum-utils git wget tuned sysstat iotop perf nc telnet vim bash-completion lsof mlocate openssl

echo ">>> Installing things that Siebrand cares about"
yum install -y bzip2 nfs-utils nmap screen tmpwatch tree zip

echo ">>> Installing EPEL-based sysadmin tools"
if yum repolist | grep -q ^epel
then
    echo ">>>> EPEL is already installed"
else
    rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
fi
yum install -y atop bash-completion-extras htop iftop nload tcping jq

echo ">>> Installing AWS cli"
yum install -y python2-pip
pip install --upgrade pip
pip install awscli --upgrade

echo ">>> Installing AWS CloudFormation Helper Scripts"
/usr/bin/easy_install --script-dir /opt/aws/bin https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
for i in `/bin/ls -1 /opt/aws/bin/`
do
    ln -sf /opt/aws/bin/$i /usr/bin/
done
