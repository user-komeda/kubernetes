#!/bin/bash

ETCD_VERSION="v3.5.15"
CONTROL01=192.168.56.11
CONTROL02=192.168.56.12
ETCD_NAME=$(hostname -s)
curl -sLO https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
tar xzvf ./etcd-${ETCD_VERSION}-linux-amd64.tar.gz
sudo mv etcd-${ETCD_VERSION}-linux-amd64/etcd* /usr/bin/
sudo mkdir -p /etc/etcd /var/lib/etcd /var/lib/kubernetes/pki
sudo cp key/etcd-server.key key/etcd-server.crt /etc/etcd/
sudo cp key/ca.crt /var/lib/kubernetes/pki/
sudo chown root:root /etc/etcd/*
sudo chmod 600 /etc/etcd/*
sudo chown root:root /var/lib/kubernetes/pki/*
sudo chmod 600 /var/lib/kubernetes/pki/*
sudo ln -s /var/lib/kubernetes/pki/ca.crt /etc/etcd/ca.crt

 cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart= setpriv /usr/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/etcd-server.crt \\
  --key-file=/etc/etcd/etcd-server.key \\
  --peer-cert-file=/etc/etcd/etcd-server.crt \\
  --peer-key-file=/etc/etcd/etcd-server.key \\
  --trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-trusted-ca-file=/etc/etcd/ca.crt \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${PRIMARY_IP}:2380 \\
  --listen-peer-urls https://${PRIMARY_IP}:2380 \\
  --listen-client-urls https://${PRIMARY_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${PRIMARY_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster controlplane01=https://${CONTROL01}:2380,controlplane02=https://${CONTROL02}:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable etcd
  sudo systemctl start etcd