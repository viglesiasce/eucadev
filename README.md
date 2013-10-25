eucadev
=======

Tools for Eucalyptus developers

## Dev environment in a VM

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
```bash
    git clone https://github.com/eucalyptus/eucadev.git
````
1. Start the VM and wait for it to build
```bash
cd eucadev; vagrant up
```

