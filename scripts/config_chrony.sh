#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Configure and enable chrony"
# Use Amazon Time Sync Service
# See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/set-time.html for details
# Remove superfluous server configurations
sed -i '/^server [123]/d' /etc/chrony.conf
sed -i 's/0.centos.pool.ntp.org/169.254.169.123 prefer/' /etc/chrony.conf
# enable chronyd (better than NTP)
systemctl enable chronyd.service
