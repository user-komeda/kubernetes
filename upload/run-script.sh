#!/bin/bash
sudo chmod +x ./ssh-key.sh
sudo chmod +x ./install-kubectl.sh
sudo chmod +x ./certificates-settings.sh
sudo chmod +x ./cert_verify.sh
sudo chmod +x ./generate-kubeconfig.sh
sudo chmod +x ./data-encryption-config.sh

./ssh-key.sh
./install-kubectl.sh
./certificates-settings.sh
./generate-kubeconfig.sh
./data-encryption-config.sh
#./cert_verify.sh