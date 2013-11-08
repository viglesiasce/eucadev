#!/bin/bash -x

export IP=$(/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | cut -d' ' -f1)
export PYTHONUNBUFFERED=1 # so ansible-playbook output appears "live"
export EUCALYPTUS_SRC=/root/eucalyptus
export EUCALYPTUS=/opt/eucalyptus
export DEST=/opt
export EPHEMERAL=/dev/vdb

msg() {  # a colorful status output, with a timestamp
    echo
    echo -n $(date)
    echo -ne " \e[1;33m" # turn on color
    printf "%04d %s" "$SECONDS" "$1"
    echo -e "\e[0m" # turn off color
    echo
}

if [ -e $EPHEMERAL ]; then
    msg "Detected ephemeral space. Mounting for use."
    mkfs.ext4 -F $EPHEMERAL
    mount $EPHEMERAL $DEST
fi

msg "enabling password-less login on the node for root"
ssh-keygen -f /root/.ssh/id_rsa -P ''
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod og-r /root/.ssh/authorized_keys
ssh-keyscan $IP >> /root/.ssh/known_hosts

msg "Disabling SElinux"
setenforce 0
sed -i -e "s/^SELINUX=enforcing.*$/SELINUX=disabled/" /etc/sysconfig/selinux

msg "installing EPEL repo, needed for PyYAML, which is needed for ansible"
yum install -y http://mirror.ancl.hawaii.edu/linux/epel/6/i386/epel-release-6-8.noarch.rpm

msg "installing git and then ansible, via git"
yum install -y git ansible
echo "$IP" > /root/ansible_hosts

msg "installing Euca cloud-playbook and configuring it"
git clone https://github.com/mspaulding06/cloud-playbook $DEST/cloud-playbook
cp $DEST/cloud-playbook/examples/cloud_config.yml $DEST/cloud-playbook/cloud_config.yml
sed -i -e "s/^ntp_server:.*$/ntp_server: pool.ntp.org/" $DEST/cloud-playbook/cloud_config.yml
sed -i -e "s/^eucalyptus_commit_ref:.*$/eucalyptus_commit_ref: add-qemu/" $DEST/cloud-playbook/cloud_config.yml
sed -i -e "s#^eucalyptus_github_repo:.*\$#eucalyptus_github_repo: https://github.com/dmitrii/eucalyptus.git#" $DEST/cloud-playbook/cloud_config.yml
echo "machine00 ansible_ssh_host=$IP

[cloud_controller]
machine00

[cluster_controller]
machine00

[storage_controller]
machine00

[walrus]
machine00

[node_controller]
machine00
" >$DEST/cloud-playbook/cloud_hosts

msg "running Euca cloud-playbook: this will take a *while*"
ansible-playbook --verbose $DEST/cloud-playbook/playbooks/source.yml --inventory-file=$DEST/cloud-playbook/cloud_hosts

# setting things up for Euca to run (this should eventually be moved into playbooks or eutester or somewhere else)

msg "switching ownership from 'root' to 'eucalyptus' user for $EUCALYPTUS"
chown -R eucalyptus.eucalyptus $EUCALYPTUS
chown root.eucalyptus $EUCALYPTUS/usr/lib/eucalyptus/euca_*
chmod 4750 $EUCALYPTUS/usr/lib/eucalyptus/euca_*

msg "setting params in eucalyptus.conf"
sed -i -e "s#^EUCALYPTUS.*\$#EUCALYPTUS=\"$EUCALYPTUS\"#" $EUCALYPTUS/etc/eucalyptus/eucalyptus.conf
sed -i -e "s#^HYPERVISOR.*\$#HYPERVISOR=\"qemu\"#" $EUCALYPTUS/etc/eucalyptus/eucalyptus.conf
sed -i -e "s#^INSTANCE_PATH.*\$#INSTANCE_PATH=\"$EUCALYPTUS/var/lib/eucalyptus/instances\"#" $EUCALYPTUS/etc/eucalyptus/eucalyptus.conf

msg "increasing max process limit to accommodate CLC"
echo "* soft nproc 64000" >>/etc/security/limits.conf
echo "* hard nproc 64000" >>/etc/security/limits.conf
rm /etc/security/limits.d/90-nproc.conf # these apparently override limits.conf?

msg "installing QEMU for NC and adding 'eucalyptus' to 'kvm' group"
yum install -y libvirt kvm bc # why is 'bc' needed?! Vic said so.
usermod -a -G kvm eucalyptus

msg "installing iSCSI stuff for NC and SC"
yum install -y scsi-target-utils iscsi-initiator-utils lvm2 device-mapper-multipath

msg "adding a bridge for NC"
echo "BRIDGE=br0" >>/etc/sysconfig/network-scripts/ifcfg-eth0
echo "DEVICE=br0
TYPE=Bridge
BOOTPROTO=dhcp
ONBOOT=yes
DELAY=0" >/etc/sysconfig/network-scripts/ifcfg-br0
service network restart

msg "policykit/dbus woodoo for NC to talk to libvirt"
cp $EUCALYPTUS_SRC/tools/eucalyptus-nc-libvirt.pkla \
  /var/lib/polkit-1/localauthority/10-vendor.d/eucalyptus-nc-libvirt.pkla
dbus-uuidgen > /var/lib/dbus/machine-id
service messagebus restart

msg "installing and configuring eutester for an all-in-one Euca deployment"
git clone https://github.com/eucalyptus/eutester.git $DEST/eutester
pushd $DEST/eutester
python setup.py install # apparently, this doesn't work with an absolute path?
popd
echo "$IP CENTOS 6.4 64 BZR [CC00 CLC SC00 WS NC00]" >$DEST/eutester/config
yum install -y PyGreSQL # otherwise euca_conf returns the 'None' error
echo "export PATH=$PATH:$EUCALYPTUS/usr/sbin/" >>/root/.bashrc # so admin commands can be found
export PATH=$PATH:$EUCALYPTUS/usr/sbin/ # so euca_conf can be found below

msg "driving Euca configuration with Eutester"
python $DEST/eutester/testcases/cloud_admin/install_euca.py --config=$DEST/eutester/config --tests initialize_db sync_ssh_keys remove_host_check configure_network start_components wait_for_creds register_components set_block_storage_manager --vnet-publicips "172.16.1.1-172.16.1.20"

msg "getting credentials from a running Euca installation"
euca_conf --get-credentials /root/creds.zip
pushd /root
unzip creds.zip
source eucarc
euca-describe-availability-zones verbose

msg "installing a test image"
eustore-install-image -b my-first-image -i $(eustore-describe-images | egrep "cirros.*kvm" | head -1 | cut -f 1)

msg "adding an ssh keypair"
euca-create-keypair my-first-keypair >/root/my-first-keypair
chmod 0600 /root/my-first-keypair

msg "running an instance"
euca-run-instances -k my-first-keypair $(euca-describe-images | grep my-first-image | grep emi | cut -f 2)

msg "fin"