# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
NUM_CONTROL_NODES = 2
NUM_WORKER_NODE = 2

# Host address start points
MASTER_IP_START = 10
NODE_IP_START = 20
LB_IP_START = 30
IP_NW = "192.168.56."


def setup_dns(node)
  # Set up /etc/hosts
  node.vm.provision "setup-hosts", :type => "shell", :path => "script/setup-hosts.sh" do |s|
    s.args = ["enp0s8", node.vm.hostname]
  end
  # Set up DNS resolution
  node.vm.provision "setup-dns", type: "shell", :path => "script/update-dns.sh"
end

# Runs provisioning steps that are required by masters and workers
def provision_kubernetes_node(node)
  # Set up kernel parameters, modules and tunables
  node.vm.provision "setup-kernel", :type => "shell", :path => "script/setup-kernel.sh"
  # Set up ssh
  node.vm.provision "setup-ssh", :type => "shell", :path => "script/ssh.sh"
  # Set up DNS
  setup_dns node
  # Install cert verification script
  # node.vm.provision "shell", inline: "ln -s script/cert_verify.sh /home/vagrant/cert_verify.sh"
end

Vagrant.configure("2") do |config|
  #config.ssh.password = "e43b35d5be0112aeaa005902"
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.
  
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box_check_update = false
  config.vm.box = "almalinux/9"
  # Provision Control Nodes
  (1..NUM_CONTROL_NODES).each do |i|
    config.vm.define "controlplane0#{i}" do |node|
    # Name shown in the GUI
    node.vm.provider :libvirt do |vb|
     # vb.name = "kubernetes-ha-controlplane-#{i}"
      vb.memory =8192
      vb.cpus = 2
      vb.default_prefix = ""
    end
    node.vm.hostname = "controlplane0#{i}"
    node.vm.network :private_network, ip: IP_NW + "#{MASTER_IP_START + i}"
    node.vm.network "forwarded_port", guest: 22, host: "#{2710 + i}"
    provision_kubernetes_node node
    if i == 1
      # Install (opinionated) configs for vim and tmux on controlplane01. These used by the author for CKA exam.
      node.vm.provision "shell", inline: "sudo dnf -y install expect"
      node.vm.provision "file", source: "upload/tmux.conf", destination: "$HOME/.tmux.conf"
      node.vm.provision "file", source: "upload/vimrc", destination: "$HOME/.vimrc"
      node.vm.provision "file", source: "upload/approve-csr.sh", destination: "$HOME/approve-csr.sh"
      node.vm.provision "file", source: "upload/ssh-key.sh", destination: "$HOME/ssh-key.sh"
      node.vm.provision "file", source: "upload/install-kubectl.sh", destination: "$HOME/install-kubectl.sh"
      node.vm.provision "file", source: "upload/certificates-settings.sh", destination: "$HOME/certificates-settings.sh"
      node.vm.provision "file", source: "script/cert_verify.sh", destination: "$HOME/cert_verify.sh"
      node.vm.provision "file", source: "upload/run-script.sh", destination: "$HOME/run-script.sh"
      node.vm.provision "file", source: "upload/generate-kubeconfig.sh", destination: "$HOME/generate-kubeconfig.sh"
      node.vm.provision "file", source: "upload/data-encryption-config.sh", destination: "$HOME/data-encryption-config.sh"
      node.vm.provision "file", source: "upload/etcd-cluster-settings.sh", destination: "$HOME/etcd-cluster-settings.sh"
      node.vm.provision "file", source: "upload/kubernetes-control-plane-settings.sh", destination: "$HOME/kubernetes-control-plane-settings.sh"
      node.vm.provision "file", source: "upload/haproxy-settings.sh", destination: "$HOME/haproxy-settings.sh"
    end
  end
end

# Provision Load Balancer Node
config.vm.define "loadbalancer" do |node|
  node.vm.provider :libvirt do |vb|
    #vb.name = "kubernetes-ha-lb"
    vb.memory = 512
    vb.cpus = 1
    vb.default_prefix = ""
  end
  node.vm.hostname = "loadbalancer"
  node.vm.network :private_network, ip: IP_NW + "#{LB_IP_START}"
  node.vm.network "forwarded_port", guest: 22, host: 2730
  # Set up ssh
  node.vm.provision "setup-ssh", :type => "shell", :path => "script/ssh.sh"
  node.vm.provision "shell", inline: "sudo dnf -y install haproxy"
  setup_dns node
end

# Provision Worker Nodes
(1..NUM_WORKER_NODE).each do |i|
  config.vm.define "node0#{i}" do |node|
  node.vm.provider :libvirt do |vb|
    #vb.name = "kubernetes-ha-node-#{i}"
    vb.memory = 8192
    vb.cpus = 2
    vb.default_prefix = ""
  end
  node.vm.hostname = "node0#{i}"
  node.vm.network :private_network, ip: IP_NW + "#{NODE_IP_START + i}"
  node.vm.network "forwarded_port", guest: 22, host: "#{2720 + i}"
  provision_kubernetes_node node
end
end
end
