# -*- mode: ruby -*-
# vi: set ft=ruby :
options = {
  :cores => 2,
  :memory => 1024,
}
CENTOS = {
  box: "centos",
  url: "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130427.box"
}
OS = CENTOS
Vagrant.configure("2") do |config|
    config.vm.define "euca-all" do |u|
      u.vm.hostname = "euca-all"
      u.vm.synced_folder "eucalyptus-src", "/opt/eucalyptus-src", :create => true
      u.vm.box = OS[:box]
      u.vm.box_url = OS[:url]
      u.vm.network :forwarded_port, guest: 8080, host: 8080
      u.vm.network :forwarded_port, guest: 8443, host: 8443
      u.vm.network :forwarded_port, guest: 8773, host: 8773
      u.vm.network :forwarded_port, guest: 8774, host: 8774
      u.vm.network :forwarded_port, guest: 8775, host: 8775
      u.vm.provider :virtualbox do |v| 
            v.customize ["modifyvm", :id, "--memory", options[:memory].to_i]
      	    v.customize ["modifyvm", :id, "--cpus", options[:cores].to_i]
      end 
      u.vm.provision :shell, :path => "eucadev.sh"
    end
end
