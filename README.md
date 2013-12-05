eucadev
=======

_Tools for Eucalyptus developers and testers._ This collection of tools allows one to deploy a Eucalyptus cloud in a virtual environment—a Vagrant-provisioned VM or a AWS/Eucalyptus-provisioned instance—with minimal effort. Currently, only single-node installations are supported, but we have plans to support multiple nodes, bare-metal provisioining, etc.



## Dev/test environment in a VirtualBox VM

The following method will give you a dev/test environment 
in a single virtual machine, with all components deployed in it.
The components will be built from latest source, which can be 
modified and immediately tested on the VM. The source will 
be located on a 'synced folder' (eucalyptus-src), which can be
edited on the host system but built on the guest system.

1. Install [VirtualBox](https://www.virtualbox.org)

2. Install [Vagrant](http://www.vagrantup.com/)

3. Install [git](http://git-scm.com)

4. Check out [eucadev](https://github.com/eucalyptus/eucadev) (ideally [fork](http://help.github.com/fork-a-repo/) it and clone the fork to your local machine, so you can contribute):

        $ git clone https://github.com/eucalyptus/eucadev.git

5. Start the VM and wait for eucadev to install Eucalyptus in it (may take a long time, _over 30 min_):

        $ cd eucadev; vagrant up
        
#### What now?

* Connect to the Eucalyptus admin console: 
  * In a Web browser on your host, go to `https://localhost:8443`
  * Accept the untrusted server certificate
  * Use `admin` for _both_ login and password
  * After a forced change of the password to something other than `admin` you'll be good to go
  
* Install [euca2ools](https://github.com/eucalyptus/euca2ools) on your host and control the cloud from the command line:

        $ source creds/eucarc
        $ euca-describe-instances 
        RESERVATION	r-49C1448D	539043227142	default
        INSTANCE	i-E4C54166	emi-34793865	192.168.192.102	1.0.217.179	running	my-first-keypair	0		m1.small	2013-12-05T23:11:59.118Z	cluster1	eki-58DF396F	eri-BB603B1C		        monitoring-disabled	192.168.192.102	1.0.217.179			instance-store					paravirtualized				
        TAG	instance	i-E4C54166	euca:node	10.0.2.15
        
  * **Note:** you won't be able to connect to cloud instances from your host, only from inside the VM.
        
        
## Dev/test environment in AWS or Eucalyptus

The following method will give you a dev/test environment 
in a single cloud instance, with all components deployed in it.
(Yes, you can run a Eucalyptus cloud in a Eucalyptus cloud or
in an Amazon cloud.)
The components will be built from latest source, which can be 
modified and immediately tested on the VM.

1. Install [Vagrant](http://www.vagrantup.com/)

2. Install the Vagrant-AWS plugin:

        vagrant plugin install vagrant-aws
3. Check out [eucadev](https://github.com/eucalyptus/eucadev) (ideally [fork](http://help.github.com/fork-a-repo/) it and clone the fork to your local machine, so you can contribute)

        $ git clone https://github.com/eucalyptus/eucadev.git
        
4. Edit the following parameters in `eucadev/Vagrantfile`:
 
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

5. Install a "dummy" vagrant box file to allow override of the box with the ami/emi:

        $ vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
        
6. Start the VM and wait for eucadev to install Eucalyptus in it (may take a long time, _over 30 min_):
        
        $ cd eucadev; vagrant up --provider=aws
