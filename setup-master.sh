#!/bin/bash

# This script is tested on CentOS 7 and 8

echo '#####################################'
echo "# Job 1 : Disable and turn off SWAP #"
echo '#####################################'
sed -i "s/\/swapfile/\#\/swapfile/g" /etc/fstab
cat /etc/fstab
swapoff -a

echo -e "\n \n"
echo '#####################################'
echo "# Job 2 : Enable and start Firewall #"
echo '#####################################'
systemctl enable firewalld.service
systemctl start firewalld.service
systemctl status firewalld.service

echo '############################################'
echo "# Job 3 : Allow required ports on Firewall #"
echo '############################################'
firewall-cmd --add-port=443/tcp --per
firewall-cmd --add-port=2379/tcp --per
firewall-cmd --add-port=2380/tcp --per
firewall-cmd --add-port=10250/tcp --per
firewall-cmd --add-port=10251/tcp --per
firewall-cmd --add-port=10252/tcp --per
firewall-cmd --reload

echo -e "\n \n"
echo '###########################'
echo "# Job 4 : Disable SELinux #"
echo '###########################'
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
setenforce 0

echo -e "\n \n"
echo '###############################'
echo "# Job 5 : Add Kernel settings #"
echo '###############################'
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system 


echo -e "\n \n"
echo '###############################################'
echo "# Job 6 : Install containerd and Docker CE #"
echo '###############################################'
yum -y install yum-utils
yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
yum -y install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
yum -y install docker-ce

echo -e "\n \n"
echo '#####################################333#######'
echo "# Job 7 : Start and Enable the docker Service #"
echo '########################################333####'
systemctl enable docker
systemctl start docker
systemctl status docker

echo -e "\n \n"
echo '###############################'
echo "# Job 8 : Add Kubernetes Repo #"
echo '###############################'
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
echo "# Job 9 : Install Kubernetes #"
echo '##############################'
dnf install -y kubelet kubeadm kubectl

echo -e "\n \n"
echo '###################################'
echo "# Job 10 Enable and Start kubelet #"
echo '###################################'
systemctl enable kubelet
systemctl start kubelet
systemctl status kubelet


echo -e "\n \n"
echo '#################################'
echo "# Job 11 : Updated :~# Password #"
echo '#################################'
echo -e "kubeadmin" | passwd --stdin root
sed -i 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/g' /etc/ssh/sshd_config
systemctl restart sshd.service


echo '###########################################'
echo "# Job 12 : Pull required container images #"
echo '###########################################'
kubeadm config images pull >/dev/null

echo -e "\n \n"

echo '##########################################'
echo "# Job 13 : Initialize Kubernetes Cluster #"
echo '##########################################'
kubeadm init --apiserver-advertise-address=192.168.122.100 --pod-network-cidr=10.244.0.0/16 --apiserver-bind-port=443 >> /root/kubernetes-cluster-init.log

echo -e "\n \n"

echo '############################################'
echo "# Job 14 : Deploy kube-flannel Pod Network #"
echo '############################################'
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo -e "\n \n"


echo '##########################################'
echo "# Job 15 : Generate cluster join command #"
echo '##########################################'
kubeadm token create --print-join-command > /join-cluster.sh

echo -e "\n \n"

echo '##########################################'
echo "# Job 16 : Enable kubectl autocompletion #"
echo '##########################################'
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
