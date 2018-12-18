#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Installing latest Amazon SSM agent"
# systemctl status will return a non-0 exit value if the service is not know,
# so "error on exit" has to be disabled until after this check.
set +e
systemctl status amazon-ssm-agent
if [ $? = 0 ]
then
    echo ">>>> Amazom SSM agent installed. Stop and remove it"
    systemctl stop amazon-ssm-agent
    rm -rf /var/log/amazon/ssm/*
    yum erase -y amazon-ssm-agent
else
    echo ">>>> Amazon SSM agent not yet installed"
fi
set -e
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
