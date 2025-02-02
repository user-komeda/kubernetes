sudo chmod +x ./ssh-key.sh
./ssh-key.sh
sudo chmod +x ./openssl.sh
scp -o StrictHostKeyChecking=no ./openssl.sh controlplane02:~/
./openssl.sh
ssh controlplane02  ./openssl.sh
