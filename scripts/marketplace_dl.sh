#!/bin/bash -x
set -o errexit -o nounset -o pipefail

VER_MARKETPLACE=4.0.1
VER_CHEFSERVER=12.18.14
VER_MANAGE=2.5.16
VER_PJS=2.2.8
VER_SUPERMARKET=3.1.96

DL_BASEURL="https://packages.chef.io/files/stable"

mkdir -p /var/cache/marketplace
pushd /var/cache/marketplace

echo ">>> Writing out a timestamp"
echo "This package cache was generated for AWS Native Chef Stack marketplace ${VER_MARKETPLACE} on $(date)" > TIMESTAMP

echo ">>> Downloading and caching install scripts"
curl -s -OL https://raw.githubusercontent.com/chef-customers/aws_native_chef_server/master/files/main.sh

cat > before.sh <<EOF
#!/bin/bash
exit 0
EOF

cat > after.sh <<EOF
#!/bin/bash -ex
# clean up the chef package cache, to maximize available disk space after install
rm -rf /var/cache/marketplace/*.rpm
rm -rf /var/cache/marketplace/*.aib
exit 0
EOF

chmod +x *.sh

echo ">>> Downloading and caching packages"
curl -s -OL ${DL_BASEURL}/chef-server/${VER_CHEFSERVER}/el/7/chef-server-core-${VER_CHEFSERVER}-1.el7.x86_64.rpm
ln -s chef-server-core-${VER_CHEFSERVER}-1.el7.x86_64.rpm chef-server-core.rpm

curl -s -OL ${DL_BASEURL}/chef-manage/${VER_MANAGE}/el/7/chef-manage-${VER_MANAGE}-1.el7.x86_64.rpm
ln -s chef-manage-${VER_MANAGE}-1.el7.x86_64.rpm chef-manage.rpm

curl -s -OL ${DL_BASEURL}/opscode-push-jobs-server/${VER_PJS}/el/7/opscode-push-jobs-server-${VER_PJS}-1.el7.x86_64.rpm
ln -s opscode-push-jobs-server-${VER_PJS}-1.el7.x86_64.rpm push-jobs-server.rpm

curl -s -OL ${DL_BASEURL}/supermarket/${VER_SUPERMARKET}/el/7/supermarket-${VER_SUPERMARKET}-1.el7.x86_64.rpm
ln -s supermarket-${VER_SUPERMARKET}-1.el7.x86_64.rpm supermarket.rpm

curl https://packages.chef.io/files/current/automate/latest/chef-automate_linux_amd64.zip | gunzip - > chef-automate && chmod +x chef-automate
./chef-automate airgap bundle create chef-automate.bundle

popd
