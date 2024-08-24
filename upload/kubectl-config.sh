#!/bin/bash

 LOADBALANCER=192.168.56.30
sleep 60
NODE_ID=$(kubectl get csr --kubeconfig kube-config/admin.kubeconfig | sed -n '2,$p' | cut -c 1-9)
NODE_ID_ARRAY=($NODE_ID)
echo ${#NODE_ID_ARRAY[@]} 

for i in `seq 1 ${#NODE_ID_ARRAY[@]}`
do
  kubectl certificate approve --kubeconfig kube-config/admin.kubeconfig ${NODE_ID_ARRAY[$i-1]}
done

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=key/ca.crt \
  --embed-certs=true \
  --server=https://${LOADBALANCER}:6443
kubectl config set-credentials admin \
  --client-certificate=key/admin.crt \
  --client-key=key/admin.key
kubectl config set-context kubernetes-the-hard-way \
  --cluster=kubernetes-the-hard-way \
  --user=admin
kubectl config use-context kubernetes-the-hard-way