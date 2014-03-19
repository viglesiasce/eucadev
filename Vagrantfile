# -*- mode: ruby -*-
# vi: set ft=ruby :
# Workaround for CHEF-4725
class<<Vagrant::Util::TemplateRenderer;alias r render;def render(*a);r(*a)<<(a[0]=~/solo$/?"\nlog_location STDOUT":"");end;end
options = {
  :cores => 2,
  :memory => 3072,
}
Vagrant.configure("2") do |config|
    config.omnibus.chef_version = :latest
    config.berkshelf.enabled = true
    config.vm.provision "shell", path: "eucadev_prep.sh"
    config.vm.provision :chef_solo do |chef|
      chef.roles_path = "roles"
      chef.add_role "cloud-in-a-box"  
      chef.json = { "eucalyptus" => { ## Choose whether to compile binaries from "source" or "packages"
                                      "install-type" => "packages",
                                      ## Does not change package version, use "eucalyptus-repo" variable
                                      "source-branch" => "testing",
                                      "eucalyptus-repo" => "http://release-repo.eucalyptus-systems.com/releases/eucalyptus/nightly/4.0/centos/6/x86_64/",
                                      "network" => { 'public-ips' => "192.168.192.50-192.168.192.60",
                                                     "dhcp-daemon" => "/usr/sbin/dhcpd" }
                                    }
                 }
    end
    config.vm.provision "shell", path: "eucadev_post.sh"
    config.vm.define "eucadev-all" do |u|
      u.vm.hostname = "eucadev-all"
      u.vm.box = "euca-deps"
      u.vm.box_url = "http://euca-vagrant.s3.amazonaws.com/euca-deps-virtualbox.box"
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
      u.vm.provider :vmware_fusion do |v|
        u.vm.box_url = "http://euca-vagrant.s3.amazonaws.com/euca-deps-vmware.box"
        v.vmx["memsize"] = options[:memory].to_i
        v.vmx["numvcpus"] = options[:cores].to_i
        v.vmx["vhv.enable"] = "true"
      end
      u.vm.provider :aws do |aws,override|
        u.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
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
