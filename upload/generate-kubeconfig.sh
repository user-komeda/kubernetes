#!/bin/bash

LOADBALANCER=192.168.56.30
mkdir kube-config

  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=/var/lib/kubernetes/pki/ca.crt \
    --server=https://${LOADBALANCER}:6443 \
    --kubeconfig=kube-config/kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=/var/lib/kubernetes/pki/kube-proxy.crt \
    --client-key=/var/lib/kubernetes/pki/kube-proxy.key \
    --kubeconfig=kube-config/kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-config/kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-config/kube-proxy.kubeconfig

    kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=/var/lib/kubernetes/pki/ca.crt \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-config/kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=/var/lib/kubernetes/pki/kube-controller-manager.crt \
    --client-key=/var/lib/kubernetes/pki/kube-controller-manager.key \
    --kubeconfig=kube-config/kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-config/kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-config/kube-controller-manager.kubeconfig

    kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=/var/lib/kubernetes/pki/ca.crt \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-config/kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=/var/lib/kubernetes/pki/kube-scheduler.crt \
    --client-key=/var/lib/kubernetes/pki/kube-scheduler.key \
    --kubeconfig=kube-config/kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-config/kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-config/kube-scheduler.kubeconfig

    kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=key/ca.crt \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-config/admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=key/admin.crt \
    --client-key=key/admin.key \
    --embed-certs=true \
    --kubeconfig=kube-config/admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=kube-config/admin.kubeconfig

  kubectl config use-context default --kubeconfig=kube-config/admin.kubeconfig

expect -c "
spawn scp -o StrictHostKeyChecking=no -r kube-config/ controlplane01:~/
expect \"vagrant@controlplane01's password:\"
send \"vagrant\n\"
interact
"
  
  scp -o StrictHostKeyChecking=no -r kube-config/ controlplane02:~/

for instance in node01 node02 ; do
  scp kube-config/kube-proxy.kubeconfig ${instance}:~/
done