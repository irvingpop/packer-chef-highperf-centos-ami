#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Installing things that Irving cares about"
yum -y install lvm2 xfsprogs python-setuptools yum-utils git wget tuned sysstat iotop perf nc telnet vim bash-completion lsof mlocate openssl

echo ">>> Installing things that Siebrand cares about"
yum install -y bzip2 nfs-utils nmap screen tmpwatch tree zip

echo ">>> Installing AWS cli"
yum erase -y awscli python2-botocore python-s3transfer
curl -sOL https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /bin/aws
rm -rf awscli-bundle awscli-bundle.zip

echo ">>> Installing AWS CloudFormation Helper Scripts"
/usr/bin/easy_install --script-dir /opt/aws/bin https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
for i in `/bin/ls -1 /opt/aws/bin/`
do
    ln -sf /opt/aws/bin/$i /usr/bin/
done

echo ">>> Installing EPEL-based sysadmin tools"
if yum repolist | grep -q ^epel
then
    echo ">>>> EPEL is already installed"
else
    rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
fi
yum install -y atop bash-completion-extras htop iftop nload tcping jq
