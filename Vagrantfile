# -*- mode: ruby -*-
# vi: set ft=ruby :
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
    config.omnibus.chef_version = :latest
    config.berkshelf.enabled = true
    config.vm.provision "shell", path: "eucadev_prep.sh"
    config.vm.provision :chef_solo do |chef|
      chef.roles_path = "roles"
      chef.add_role "cloud-in-a-box"
      chef.json = { "eucalyptus" => { "install-type" => "source",
                                      "source-branch" => "maint/3.4/testing",
                                      "network" => { 'public-ips' => "192.168.192.50-192.168.192.60" }
                                    }
                 }
    end
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
      u.vm.provider :aws do |aws,override|
	aws.access_key_id = "XXXXXXXXXXXXXXXXXXXXXXX"
        aws.secret_access_key = "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
        aws.instance_type = "cc1.4xlarge"
        # Optional
        aws.keypair_name = "my-keypair"
        aws.ami = "emi-MYEMIHERE"
        override.ssh.username ="root"
        # Optional
        aws.region = "eucalyptus"
        aws.endpoint = "http://EUCALYPTUS_CLC_IP:8773/services/Eucalyptus"
        override.ssh.private_key_path ="/path/to/ssh/key"
        aws.instance_ready_timeout = 480
        aws.tags = {
                Name: "EucaDev",
        } 
     end
  end
end
