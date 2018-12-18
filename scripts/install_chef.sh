#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo ">>> Installing Chef Workstation (includes ChefDK)"
curl -LO https://omnitruck.chef.io/install.sh && sudo bash ./install.sh -P chef-workstation && rm install.sh
