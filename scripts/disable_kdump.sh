#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Disable kdump"
systemctl disable kdump.service
