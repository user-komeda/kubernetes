#!/bin/bash

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

scp encryption-config.yaml controlplane01:~/
scp encryption-config.yaml controlplane02:~/
ssh controlplane01 sudo mkdir -p /var/lib/kubernetes/ &&
ssh controlplane01 sudo mv encryption-config.yaml /var/lib/kubernetes/
ssh controlplane02 sudo mkdir -p /var/lib/kubernetes/
ssh controlplane02 sudo mv encryption-config.yaml /var/lib/kubernetes/