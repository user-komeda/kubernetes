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

  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=/var/lib/kubernetes/pki/ca.crt \
    --server=https://${LOADBALANCER}:6443 \
    --kubeconfig=kube-config/node01.kubeconfig

  kubectl config set-credentials system:node:node01 \
    --client-certificate=/var/lib/kubernetes/pki/node01.crt \
    --client-key=/var/lib/kubernetes/pki/node01.key \
    --kubeconfig=kube-config/node01.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:node01 \
    --kubeconfig=kube-config/node01.kubeconfig

  kubectl config use-context default --kubeconfig=kube-config/node01.kubeconfig

  scp -o StrictHostKeyChecking=no -r kube-config/ controlplane01:~/
  scp -o StrictHostKeyChecking=no -r kube-config/ controlplane02:~/
  scp -o StrictHostKeyChecking=no key/ca.crt key/node01.crt key/node01.key kube-config/node01.kubeconfig node01:~/


for instance in node01 node02 ; do
  scp kube-config/kube-proxy.kubeconfig ${instance}:~/
done