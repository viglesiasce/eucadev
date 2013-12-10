# -*- mode: ruby -*-
# vi: set ft=ruby :
method = "source"
#method = "package"
options = {
  :cores => 2,
  :memory => 3072,
}
CENTOS = {
  box: "centos",
  url: "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130427.box"
}
OS = CENTOS
Vagrant.configure("2") do |config|
    config.vm.define "eucadev-all" do |u|
      u.vm.hostname = "eucadev-all"
      u.vm.box = OS[:box]
      u.vm.box_url = OS[:url]
      u.vm.network :forwarded_port, guest: 8080, host: 8080
      u.vm.network :forwarded_port, guest: 8443, host: 8443
      u.vm.network :forwarded_port, guest: 8773, host: 8773
      u.vm.network :forwarded_port, guest: 8774, host: 8774
      u.vm.network :forwarded_port, guest: 8775, host: 8775
      u.vm.network :private_network, ip: "192.168.192.101"
      u.vm.provider :virtualbox do |v| 
            v.customize ["modifyvm", :id, "--memory", options[:memory].to_i]
      	    v.customize ["modifyvm", :id, "--cpus", options[:cores].to_i]
      end
      u.vm.provision :shell, :inline => "/vagrant/eucadev.sh eth1 " + method

      u.vm.provider :aws do |aws,override|
        aws.access_key_id = "XXXXXXXXXXXXXXXXXXXXXXXX"
        aws.secret_access_key = "YYYYYYYYYYYYYYYYYYYYYYYYYY"
        aws.instance_type = "m3.2xlarge"
        # Optional
        aws.availability_zone = "two"
        aws.keypair_name = "my-key"
        aws.ami = "emi-1873419A"
        override.ssh.username ="root"
        override.ssh.private_key_path ="/path/to/my/key.pem"
        # Optional
        aws.security_groups = ["Eucalyptus"]
        aws.region = "eucalyptus"
        aws.endpoint = "http://my-clc-ip:8773/services/Eucalyptus"
        aws.instance_ready_timeout = 240
        aws.tags = {
                Name: "EucaDev",
        }
	override.vm.provision :shell, :inline => "/vagrant/eucadev.sh eth0 " + method
      end 
    end
end
