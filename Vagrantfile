# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-18.04"

  config.vm.define "dbmetrics" do |dbmetrics|
    dbmetrics.vm.hostname = "dbmetrics"
    dbmetrics.vm.network "private_network", ip: "10.0.0.45"
    dbmetrics.vm.network "public_network", ip: "192.168.1.155"

    config.vm.synced_folder ".", "/vagrant"
    dbmetrics.vm.provision "shell", path: "scripts/postgres_install.sh"
  end

  config.vm.define "node1" do |node|
    node.vm.hostname = "node1"
    node.vm.network "private_network", ip: "10.0.0.50"
    node.vm.network "public_network", ip: "192.168.1.156"

    config.vm.provision "file", source: "./services/metrics", destination: "/home/vagrant/services/metrics"
    config.vm.provision "shell", inline: <<-SHELL
      sudo chown -R metric_service:metric_service /home/vagrant/services/metrics
      sudo chmod -R 755 /home/vagrant/services/metrics
    SHELL
    node.vm.provision "shell", path: "scripts/setup_app_metrics.sh"
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
end
