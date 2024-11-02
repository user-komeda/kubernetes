#!/bin/bash

LOADBALANCER=192.168.56.30
POD_CIDR=10.244.0.0/16
SERVICE_CIDR=10.96.0.0/16
CLUSTER_DNS=$(echo $SERVICE_CIDR | awk 'BEGIN {FS="."} ; { printf("%s.%s.%s.10", $1, $2, $3) }')
KUBE_VERSION_DELETE_ZERO=$(curl -L -s https://dl.k8s.io/release/stable.txt | awk '{print substr($0, 1, length($0)-2)}') 
KUBE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt) 

sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/${KUBE_VERSION_DELETE_ZERO}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/${KUBE_VERSION_DELETE_ZERO}/rpm/repodata/repomd.xml.key
EOF
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sudo dnf install -y containerd.io  kubectl
sudo mkdir -p /etc/containerd
sudo containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd

sudo curl -sLO https://dl.k8s.io/${KUBE_VERSION}/bin/linux/amd64/kube-proxy
sudo curl -sLO https://dl.k8s.io/${KUBE_VERSION}/bin/linux/amd64/kubelet


sudo mkdir -p \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes/pki \
  /var/run/kubernetes

sudo  chmod +x kube-proxy kubelet
sudo mv kube-proxy kubelet /usr/bin/

  sudo mv ca.crt kube-proxy.crt kube-proxy.key /var/lib/kubernetes/pki
  sudo chown root:root /var/lib/kubernetes/pki/*
  sudo chmod 600 /var/lib/kubernetes/pki/*



  sudo kubectl config --kubeconfig=/var/lib/kubelet/bootstrap-kubeconfig \
    set-cluster bootstrap --server="https://${LOADBALANCER}:6443" --certificate-authority=/var/lib/kubernetes/pki/ca.crt

  sudo kubectl config --kubeconfig=/var/lib/kubelet/bootstrap-kubeconfig \
    set-credentials kubelet-bootstrap --token=07401b.f395accd246ae52d

  sudo kubectl config --kubeconfig=/var/lib/kubelet/bootstrap-kubeconfig \
    set-context bootstrap --user=kubelet-bootstrap --cluster=bootstrap

  sudo kubectl config --kubeconfig=/var/lib/kubelet/bootstrap-kubeconfig \
    use-context bootstrap
  
cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: /var/lib/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
containerRuntimeEndpoint: unix:///var/run/containerd/containerd.sock
cgroupDriver: systemd
clusterDomain: "cluster.local"
clusterDNS:
  - ${CLUSTER_DNS}
registerNode: true
resolvConf: /run/systemd/resolve/resolv.conf
rotateCertificates: true
runtimeRequestTimeout: "15m"
serverTLSBootstrap: true
EOF

cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/bin/kubelet \\
  --bootstrap-kubeconfig="/var/lib/kubelet/bootstrap-kubeconfig" \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --cert-dir=/var/lib/kubelet/pki/ \\
  --node-ip=${PRIMARY_IP} \\
  --v=2

[Install]
WantedBy=multi-user.target
EOF

sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/
sudo chown root:root /var/lib/kube-proxy/kube-proxy.kubeconfig
sudo chmod 600 /var/lib/kube-proxy/kube-proxy.kubeconfig

cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: /var/lib/kube-proxy/kube-proxy.kubeconfig
mode: iptables
clusterCIDR: ${POD_CIDR}
EOF

cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable kubelet kube-proxy
  sudo systemctl start kubelet kube-proxy

