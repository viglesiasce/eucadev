eucadev
=======

Tools for Eucalyptus developers

## Dev environment in a VM

This will give a full development environment in a single virtual machine, with all components deployed and configured in it.

1. Install [VirtualBox](https://www.virtualbox.org)
1. Install [Vagrant](http://www.vagrantup.com/)
1. Install [git](http://git-scm.com)
1. Check out [eucadev](https://github.com/eucalyptus/eucadev) (ideally [http://help.github.com/fork-a-repo/](fork) it so you can contribute)
``` 
git clone https://github.com/eucalyptus/eucadev.git
```
1. Start the VM and wait for it to build
```
cd eucadev; vagrant up
```

