#!/bin/bash

# Point to Google's DNS server
sudo sed -i -e 's/#DNS=/DNS=8.8.8.8/' /etc/resolv.conf

sudo systemctl reload NetworkManager