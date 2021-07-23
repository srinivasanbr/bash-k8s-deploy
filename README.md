### This document provides a How-to for deploying K8s cluster on VM's using the `$SHELL`  

## Table of Contents      
1) [Requirements](#)       
	* [Virtual Machines](#)      
2) [Install K8s](#)     

## Requirements      
### Virtual Machines     
- Spin up `3` Virtual Machine's on your Bare Metal Server       
- Node: **Minimum System Requirement: 2 vCPUs ᛫ 4Gib RAM**       
- Enable Passwordless Authentication between the VM's      

## Install K8s           
- Clone this repository         
```bash       
git clone https://github.com/srinivasanbr/bash-k8s-deploy.git       
```      
- Note: **Execute script as :~#**     
- Replace the IP addresses inside the `setup-hosts.sh` script with the ones assigned to your VM's, `cp` and `./` the script against it, `less`  `/etc/hosts` for validation    

```bash      
bash setup-hosts.sh      
```     
- Similarly, `cp` over the `setup-master.sh` and `setup-node.sh` onto your Master and `./` the script in a sequence.      
```bash      
bash setup-master.sh      
```      
```bash      
bash setup-node.sh      
```     
- Note: **You'll have to wait until the `setup-master.sh` script completes it execution**  