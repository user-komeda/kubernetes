#!/bin/bash
sudo chmod +x ./ssh-key.sh
sudo chmod +x ./install-kubectl.sh
sudo chmod +x ./certificates-settings.sh
sudo chmod +x ./cert_verify.sh
sudo chmod +x ./generate-kubeconfig.sh
sudo chmod +x ./data-encryption-config.sh
sudo chmod +x ./etcd-cluster-settings.sh

./ssh-key.sh
./install-kubectl.sh
./certificates-settings.sh
./generate-kubeconfig.sh
./data-encryption-config.sh
scp -o StrictHostKeyChecking=no ./etcd-cluster-settings.sh controlplane01:~/
scp -o StrictHostKeyChecking=no ./etcd-cluster-settings.sh controlplane02:~/
ssh controlplane01  ./etcd-cluster-settings.sh
ssh controlplane02  ./etcd-cluster-settings.sh
#ssh controlplane02 sh ./etcd-cluster-settings.sh  && sh ./start-etcd.sh
#ssh controlplane01 sh ./start-etcd.sh 
#ssh controlplane02 sh ./start-etcd.sh 
#./cert_verify.sh