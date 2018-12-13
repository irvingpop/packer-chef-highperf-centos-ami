#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Set journald limits"
mkdir -p /etc/systemd/journald.conf.d/
echo -e "[Journal]\nRateLimitBurst=15000\nRateLimitInterval=30s\nSystemMaxUse=10G" > /etc/systemd/journald.conf.d/dcos-el7.conf
