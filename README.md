eucadev
=======

Tools for Eucalyptus developers

## Dev environment in a  VirtualBox VM

The following method will give you a development environment 
in a single virtual machine, with all components deployed in it.
The components will be built from latest source, which can be 
modified and immediately tested on the VM. The source will 
be located on a 'synced folder' (eucalyptus-src), which can be
edited on the host system but built on the guest system.

1. Install [VirtualBox](https://www.virtualbox.org)
1. Install [Vagrant](http://www.vagrantup.com/)
1. Install [git](http://git-scm.com)
1. Check out [eucadev](https://github.com/eucalyptus/eucadev) (ideally [fork](http://help.github.com/fork-a-repo/) it so you can contribute)
   - `git clone https://github.com/eucalyptus/eucadev.git`
1. Start the VM and wait for it to build (may take a long time, _over 30 min_)
   - `cd eucadev; vagrant up`

## Setting up with AWS or Eucalyptus
1.  Download and install [Vagrant](http://www.vagrantup.com/)

2. Install the Vagrant-AWS plugin: 
   ```
	vagrant plugin install vagrant-aws
   ```

3. Do a fork of eucadev project (requires github account for information on how to set up a Github account, refer to the following URL: [http://help.github.com/set-up-git-redirect/](http://help.github.com/set-up-git-redirect/)).  On information on how to fork a project, refer to the following link: [http://help.github.com/fork-a-repo/](http://help.github.com/fork-a-repo/).

4. Clone your fork to your local machine.

5. Edit the following parameters in the Vagrantfile:
    ```     
    aws.access_key_id = "XXXXXXXXXXXXXXXXXX"
    aws.secret_access_key = "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
    aws.instance_type = "m1.medium"
    ## This CentOS 6 EMI needs to have the following commented out of /etc/sudoers,
    ## Defaults    requiretty
    aws.ami = "emi-1873419A"
    aws.security_groups = ["default"]
    aws.region = "eucalyptus"
    aws.endpoint = "http://10.0.1.91:8773/services/Eucalyptus"
    aws.keypair_name = "vic"
    override.ssh.username ="root"
    override.ssh.private_key_path ="/Users/viglesias/.ssh/id_rsa"
    ```

6. Install a "dummy" vagrant box file to allow override of the box with the ami/emi:
   ```
   vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
   ```
6. Once inside the repository run "vagrant up --provider=aws". This will run a virtual machine, and install the Eucalyptus development environment in your cloud.

