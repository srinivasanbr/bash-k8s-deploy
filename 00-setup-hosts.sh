#!/bin/bash

cat >>/etc/hosts<<EOF
# Kube Master
192.168.12.10 kube-master master master.example.com
# Kube Nodes
192.168.12.11 kube-node1 node1 node1.example.com
192.168.12.12 kube-node2 node2 node2.example.com
EOF

