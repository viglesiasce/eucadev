#!/bin/bash -xe

# This script is for installing cloud-in-a-box. Documentation coming soon.

if [ -z "$publicips" ];then
    echo 'Please set the "publicips" environment variable'
else
    echo "Using Public IPs: $publicips" 
fi

echo "Updating yum"
yum update -y

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

# Add tip of the day to Eucalyptus console
export UUID=`uuidgen` && sed -i "s|</body>|<iframe width=\"0\" height=\"0\" src=\"https://www.eucalyptus.com/docs/tipoftheday.html?${UUID}\" seamless=\"seamless\" frameborder=\"0\"></iframe></body>|" /usr/share/eucalyptus-console/static/index.html
