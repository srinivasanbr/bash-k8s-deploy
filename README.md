## Requirements      

1. Spin up `3` Virtual Machine's on your Bare Metal Server with minimum system requirements of 2 vCPUs and 4Gib RAM   
2. Enable Passwordless Authentication between the VM's      

## Installation           
Clone this repository         
```bash       
git clone https://github.com/srinivasanbr/bash-k8s-deploy.git       
```      
**Note:** Execute the scripts below as _:~#_    

Replace the IP addresses inside the `00-setup-hosts.sh` script with the ones assigned to your VM's, `cp` and `./` the script against it, `less`  `/etc/hosts` for validation    

```bash      
bash 00-setup-hosts.sh      
```     
Similarly, `cp` over the `10-setup-master.sh` and `30-setup-node.sh` onto your Master and `./` the script in a sequence.      
```bash      
bash 10-setup-master.sh      
```      
```bash      
bash 30-setup-node.sh      
```     
**Note:** You'll have to wait until the `setup-master.sh` script completes it execution

## ☁️ 🧪

| Platform           | Status |
| :---------         |:------:|
| AWS EC2            |   OK   |
| GCP Compute Engine |   ?    |