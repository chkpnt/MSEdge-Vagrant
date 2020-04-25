This Vagrantfile helps to setup and provision the Virtual Machine *"Windows 10 with 
Legacy Microsoft Edge and Internet Explorer 11"* provided 
[by Microsoft](https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/) for usage with Vagrant.

# Prerequisites
Only VirtualBox, Vagrant and Ansible are required. On macOS, these dependencies can be installed using Homebrew:

```
$ brew cask install virtualbox
$ brew cask install vagrant
```

For managing your Vagrant virtual machines, I can recommend the use of [Vagrant-Manager](http://vagrantmanager.com/), a small utility app for the menu bar.

```
$ brew cask install vagrant-manager
```

# Usage
The Vagrant Box from [Microsoft](https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/),
which provide *"Windows 10 with Legacy Microsoft Edge and Internet Explorer 11"*, has to be downloaded
and added into your local Vagrant installation under the name *MSEdge*. This process is automated with
the script `prepare.sh`.

To build the virtual machine based on the above Vagrant Box, you only need to execute

```
$ vagrant up
```

This will create the virtual machine, updates the VirtualBox guest tools and applies the provisioning.
This can take some time, please wait until the command terminated before using the VM. Before the VM is ready, it will be rebooted and automatically logged on.

The VM uses an account with username `IEUser` and password `Passw0rd!`. To access the VM, a remote desktop connection can be used as well:

```
$ vagrant rdp
```

The host (the computer running Vagrant) from the perspective of VM can be reached via the IP address 
`10.0.2.2` or the hostname `vagrant-host`.

So if your local running web application is listening on `*:8443`, you can access it
via `https://10.0.2.2:8443` or `https://vagrant-host:8443`. If it is listening on `localhost:8443`, 
you first have to set up a reverse ssh tunnel, so you can access it via `https://localhost:8443` 
from within the VM as well:

```
$ vagrant ssh -- -R8443:localhost:8443
```
