#!/bin/bash -xe

# This script is for installing cloud-in-a-box. Documentation coming soon.

if [ -z "$publicips" ];then
    echo 'Please set the "publicips" environment variable'
else
    echo "Using Public IPs: $publicips" 
fi

echo "Installing Chef"
curl -L https://www.opscode.com/chef/install.sh | bash > chef-install.log

### Download artifacts
if [ -z "$role" ];then
    export role=ciab
fi
echo "Using Role: $role"
 
curl http://euca-chef.s3.amazonaws.com/cookbooks.tgz > cookbooks.tgz
curl http://euca-chef.s3.amazonaws.com/ciab.json > $role.json
sed -i "s/PUBLICIPS/$publicips/g" $role.json
if [ ! -z "$bridge" ];then
    sed -i "s/eth0/$bridge/g" $role.json
fi
chef-solo -r cookbooks.tgz -j $role.json
