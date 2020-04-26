# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

    config.vm.box = "MSEdge"
    config.vm.communicator = "winrm"
    config.vm.guest = :windows

    config.winrm.username = "IEUser"
    config.winrm.password = "Passw0rd!"

    config.ssh.username = "IEUser"
    config.ssh.password = "Passw0rd!"

    # For RDP:
    config.vm.network "forwarded_port", guest: 3389, host: 3389

    config.vagrant.plugins = ["vagrant-vbguest"]
    config.vbguest.auto_update = true
    
    config.vm.provider 'virtualbox' do |vbox|
        vbox.linked_clone = true
        vbox.gui = true
        vbox.memory = 3072
        vbox.cpus = 2
        vbox.customize ['modifyvm', :id, '--graphicscontroller', 'VBoxSVGA']
        vbox.customize ['modifyvm', :id, '--accelerate2dvideo', 'on']
        vbox.customize ['modifyvm', :id, '--accelerate3d', 'on']
        vbox.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        vbox.customize ['modifyvm', :id, '--vram', '128']
        vbox.customize ['modifyvm', :id, '--hwvirtex', 'on']
        vbox.customize ['modifyvm', :id, '--clipboard-mode', 'bidirectional']
        vbox.customize ['modifyvm', :id, '--draganddrop', 'bidirectional']
    end

    config.vm.provision "file", source: "config.ps1", destination: "c:\\tmp\\config.ps1"
    config.vm.provision "shell", privileged: false, path: "provisioning.ps1", reboot: true
end
