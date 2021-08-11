#!/bin/bash

echo '#####################################'
echo "#     Disable and turn off SWAP     #"
echo '#####################################'
sed -i "s/\/swapfile/\#\/swapfile/g" /etc/fstab
cat /etc/fstab
swapoff -a

echo -e "\n \n"
echo '#####################################'
echo "#     Start and enable Firewall     #"
echo '#####################################'
systemctl enable firewalld.service
systemctl start firewalld.service
systemctl status firewalld.service

echo '############################################'
echo "#     Allow Required ports on Firewall     #"
echo '############################################'
firewall-cmd --add-port=10250/tcp --per
firewall-cmd --add-port=30000-32767/tcp --per
firewall-cmd --reload

echo -e "\n \n"
echo '###########################'
echo "#     Disable SELinux     #"
echo '###########################'
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
setenforce 0

echo -e "\n \n"
echo '###############################'
echo "#     Add Kernel settings     #"
echo '###############################'
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system 

echo -e "\n \n"
echo '###############################################'
echo "#     Install containerd.io and Docker-CE     #"
echo '###############################################'
yum -y install yum-utils
yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
yum -y install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
yum -y install docker-ce

echo -e "\n \n"
echo '###########################################'
echo "#     Start and enable docker service     #"
echo '###########################################'
systemctl enable docker
systemctl start docker
systemctl status docker

echo -e "\n \n"
echo '#######################################'
echo "#     Add Kubernetes package repo     #"
echo '#######################################'
cat >> /etc/yum.repos.d/kubernetes.repo<<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

echo -e "\n \n"
echo '##############################'
echo "#     Install Kubernetes     #"
echo '##############################'
dnf install -y kubelet kubeadm kubectl

echo -e "\n \n"
echo '####################################'
echo "#     Start and enable kubelet     #"
echo '####################################'
systemctl enable kubelet
systemctl start kubelet
systemctl status kubelet


echo -e "\n \n"
echo '######################################'
echo "#     Updated Root user Password     #"
echo '######################################'
echo -e "kubeadmin" | passwd --stdin root
sed -i 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/g' /etc/ssh/sshd_config
systemctl restart sshd.service

echo -e "\n \n"
echo '#####################################'
echo "#     Copy Cluster Join command     #"
echo '#####################################'
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no master:/join-cluster.sh  /join-cluster.sh

echo -e "\n \n"
echo '########################'
echo "#     Join Cluster     #"
echo '########################'
bash /join-cluster.sh
