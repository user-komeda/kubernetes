#!/bin/bash
sudo chmod +x ./ssh-key.sh
sudo chmod +x ./install-kubectl.sh
sudo chmod +x ./certificates-settings.sh
sudo chmod +x ./cert_verify.sh

./ssh-key.sh
./install-kubectl.sh
./certificates-settings.sh
./cert_verify.sh