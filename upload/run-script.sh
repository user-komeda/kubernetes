#!/bin/bash
sudo chmod +x ./ssh-key.sh
sudo chmod +x ./install-kubectl.sh
sudo chmod +x ./certificates-settings.sh
sudo chmod +x ./cert_verify.sh
sudo chmod +x ./generate-kubeconfig.sh
sudo chmod +x ./data-encryption-config.sh
sudo chmod +x ./etcd-cluster-settings.sh
sudo chmod +x ./kubernetes-control-plane-settings.sh
sudo chmod +x ./haproxy-settings.sh
sudo chmod +x ./setup-worker.sh

./ssh-key.sh
./install-kubectl.sh
./certificates-settings.sh
./generate-kubeconfig.sh
./data-encryption-config.sh
scp -o StrictHostKeyChecking=no ./etcd-cluster-settings.sh controlplane01:~/
scp -o StrictHostKeyChecking=no ./etcd-cluster-settings.sh controlplane02:~/
ssh controlplane01  ./etcd-cluster-settings.sh
ssh controlplane02  ./etcd-cluster-settings.sh
scp -o StrictHostKeyChecking=no ./kubernetes-control-plane-settings.sh controlplane01:~/
scp -o StrictHostKeyChecking=no ./kubernetes-control-plane-settings.sh controlplane02:~/
ssh controlplane01  ./kubernetes-control-plane-settings.sh
ssh controlplane02  ./kubernetes-control-plane-settings.sh
scp -o StrictHostKeyChecking=no ./haproxy-settings.sh loadbalancer:~/
ssh loadbalancer  ./haproxy-settings.sh
scp -o StrictHostKeyChecking=no ./setup-worker.sh node01:~/
scp -o StrictHostKeyChecking=no ./setup-worker.sh node02:~/
ssh node01  ./setup-worker.sh
ssh node02  ./setup-worker.sh
#./cert_verify.sh