#!/bin/bash

CONTROL01=192.168.56.11
CONTROL02=192.168.56.12
LOADBALANCER=192.168.56.30
SERVICE_CIDR=10.96.0.0/24
API_SERVICE=$(echo $SERVICE_CIDR | awk 'BEGIN {FS="."} ; { printf("%s.%s.%s.1", $1, $2, $3) }')
  mkdir key
  # Create private key for CA
  openssl genrsa -out key/ca.key 2048

  # Create CSR using the private key
  openssl req -new -key key/ca.key -subj "/CN=KUBERNETES-CA/O=Kubernetes" -out key/ca.csr

  # Self sign the csr using its own private key
  openssl x509 -req -in key/ca.csr -signkey key/ca.key -CAcreateserial -out key/ca.crt -days 1000

    # Generate private key for admin user
  openssl genrsa -out key/admin.key 2048

  # Generate CSR for admin user. Note the OU.
  openssl req -new -key key/admin.key -subj "/CN=admin/O=system:masters" -out key/admin.csr

  # Sign certificate for admin user using CA servers private key
  openssl x509 -req -in key/admin.csr -CA key/ca.crt -CAkey key/ca.key -CAcreateserial -out key/admin.crt -days 1000

  openssl genrsa -out key/kube-controller-manager.key 2048

  openssl req -new -key key/kube-controller-manager.key \
    -subj "/CN=system:kube-controller-manager/O=system:kube-controller-manager" -out key/kube-controller-manager.csr

  openssl x509 -req -in key/kube-controller-manager.csr \
    -CA key/ca.crt -CAkey key/ca.key -CAcreateserial -out key/kube-controller-manager.crt -days 1000

  openssl genrsa -out key/kube-proxy.key 2048

  openssl req -new -key key/kube-proxy.key \
    -subj "/CN=system:kube-proxy/O=system:node-proxier" -out key/kube-proxy.csr

  openssl x509 -req -in key/kube-proxy.csr \
    -CA key/ca.crt -CAkey key/ca.key -CAcreateserial -out key/kube-proxy.crt -days 1000

      openssl genrsa -out key/kube-scheduler.key 2048

  openssl req -new -key key/kube-scheduler.key \
    -subj "/CN=system:kube-scheduler/O=system:kube-scheduler" -out key/kube-scheduler.csr

  openssl x509 -req -in key/kube-scheduler.csr -CA key/ca.crt -CAkey key/ca.key -CAcreateserial -out key/kube-scheduler.crt -days 1000

    cat > openssl.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[v3_req]
basicConstraints = critical, CA:FALSE
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster
DNS.5 = kubernetes.default.svc.cluster.local
IP.1 = ${API_SERVICE}
IP.2 = ${CONTROL01}
IP.3 = ${CONTROL02}
IP.4 = ${LOADBALANCER}
IP.5 = 127.0.0.1
EOF

  openssl genrsa -out key/kube-apiserver.key 2048

  openssl req -new -key key/kube-apiserver.key \
    -subj "/CN=kube-apiserver/O=Kubernetes" -out key/kube-apiserver.csr -config openssl.cnf

  openssl x509 -req -in key/kube-apiserver.csr \
    -CA key/ca.crt -CAkey key/ca.key -CAcreateserial -out key/kube-apiserver.crt -extensions v3_req -extfile openssl.cnf -days 1000

cat > openssl-kubelet.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[v3_req]
basicConstraints = critical, CA:FALSE
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
EOF

  openssl genrsa -out key/apiserver-kubelet-client.key 2048

  openssl req -new -key key/apiserver-kubelet-client.key \
    -subj "/CN=kube-apiserver-kubelet-client/O=system:masters" -out key/apiserver-kubelet-client.csr -config openssl-kubelet.cnf

  openssl x509 -req -in key/apiserver-kubelet-client.csr \
    -CA key/ca.crt -CAkey key/ca.key -CAcreateserial -out key/apiserver-kubelet-client.crt -extensions v3_req -extfile openssl-kubelet.cnf -days 1000
cat > openssl-etcd.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = ${CONTROL01}
IP.2 = ${CONTROL02}
IP.3 = 127.0.0.1
EOF

  openssl genrsa -out key/etcd-server.key 2048

  openssl req -new -key key/etcd-server.key \
    -subj "/CN=etcd-server/O=Kubernetes" -out key/etcd-server.csr -config openssl-etcd.cnf

  openssl x509 -req -in key/etcd-server.csr \
    -CA key/ca.crt -CAkey key/ca.key -CAcreateserial -out key/etcd-server.crt -extensions v3_req -extfile openssl-etcd.cnf -days 1000

  openssl genrsa -out key/service-account.key 2048

  openssl req -new -key key/service-account.key \
    -subj "/CN=service-accounts/O=Kubernetes" -out key/service-account.csr

  openssl x509 -req -in key/service-account.csr \
    -CA key/ca.crt -CAkey key/ca.key -CAcreateserial -out key/service-account.crt -days 1000

expect -c "
spawn scp -o StrictHostKeyChecking=no -r key/ controlplane01:~/
expect \"vagrant@controlplane01's password:\"
send \"vagrant\n\"
interact
"
  
  scp -o StrictHostKeyChecking=no -r key/ controlplane02:~/
  scp -o StrictHostKeyChecking=no -r ./cert_verify.sh controlplane02:~/

for instance in node01 node02 ; do
  scp key/ca.crt key/kube-proxy.crt key/kube-proxy.key ${instance}:~/
done