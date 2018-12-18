#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Disable rsyslog"
systemctl disable rsyslog.service
