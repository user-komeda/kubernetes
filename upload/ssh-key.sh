#!/bin/bash

expect -c "
spawn ssh-keygen -t ed25519
expect \"Enter file in which the key is (/home/vagrant/.ssh/id_ed25519):\"
send \"\n\"
expect \"Enter passphrase (empty for no passphrase):\"
send \"\n\"
expect \"Enter same passphrase again:\"
send \"\n\"
interact
"
cat .ssh/id_ed25519.pub >> .ssh/authorized_keys
expect -c "
spawn ssh-copy-id -o StrictHostKeyChecking=no vagrant@controlplane02
expect \"vagrant@controlplane02's password:\"
send \"vagrant\n\"
interact
spawn ssh-copy-id -o StrictHostKeyChecking=no vagrant@node01
expect \"vagrant@node01's password:\"
send \"vagrant\n\"
interact
spawn ssh-copy-id -o StrictHostKeyChecking=no vagrant@node02
expect \"vagrant@node02's password:\"
send \"vagrant\n\"
interact
spawn ssh-copy-id -o StrictHostKeyChecking=no vagrant@loadbalancer
expect \"vagrant@loadbalancer's password:\"
send \"vagrant\n\"
interact
"