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
sudo chmod +x ./boot-worker-1.sh
sudo chmod +x ./auth-kubelet.sh
sudo chmod +x ./boot-worker-2.sh

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
scp -o StrictHostKeyChecking=no ./boot-worker-1.sh node01:~/
ssh node01  ./boot-worker-1.sh
ssh controlplane01 ./auth-kubelet.sh
scp -o StrictHostKeyChecking=no ./boot-worker-2.sh node02:~/
ssh node02  ./boot-worker-2.sh
sleep 60
NODE_ID=$(kubectl get csr --kubeconfig kube-config/admin.kubeconfig | sed -n '2,$p' | cut -c 1-9)
NODE_ID_ARRAY=($NODE_ID)
echo ${#NODE_ID_ARRAY[@]} 

for i in `seq 1 ${#NODE_ID_ARRAY[@]}`
do
  kubectl certificate approve --kubeconfig kube-config/admin.kubeconfig ${NODE_ID_ARRAY[$i-1]}
done

#./cert_verify.sh