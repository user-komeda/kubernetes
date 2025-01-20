#!/bin/bash -e
sed -i 's/192.168.0.0\/16/10.244.0.0\/16/g' custom-resources.yaml
kubectl create -f custom-resources.yaml
