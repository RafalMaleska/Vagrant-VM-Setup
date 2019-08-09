#!/usr/bin/env bash

## Adds your user ##
username=$1
username=echo "$username" | awk '{print tolower($0)}'
echo $username
username=rmanhart

## Set the timezone ##
timedatectl set-timezone Europe/Berlin

## Update System and Dependencies ##
apt-get update
apt-get upgrade
apt-get autoremove
sudo snap refresh


## Base Packages - Install base packages ##
apt install -y vim \
    curl \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
	wget


## Go - Install ## 
# will install also the compilers
sudo apt-get install -y golang-1.12
# but does not add to $PATH
sudo apt-get purge -y golang-1.12
# HACK: so we use snap
sudo snap install -y --classic go
go env
# update bashrc|zshrc
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH
# test via
go get -u github.com/git-chglog/git-chglog/cmd/git-chglog
git-chglog --version
	

## OpenJDK - Install ##
#apt install -y openjdk-8-jdk
apt install -y openjdk-11-jdk
# Test the installation
java -version

## Docker - Install ##
#Add docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# Add docker's stable repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable edge test" # cuz for 19.04 is no stable yet (20190602)
# Install latest stable docker ce
apt update
#apt install -y docker-ce
# Or a specific version
apt install -y docker-ce=5:18.09.0~3-0~ubuntu-bionic docker-ce-cli=5:18.09.0~3-0~ubuntu-bionic
sudo systemctl status docker
# Add user to docker group
usermod -aG docker $username
# Test the installation
docker version

## Docker Compose - Install ## 
curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# apply executable permissions to the library
chmod +x /usr/local/bin/docker-compose
# Test the installation
docker-compose --version


## Kubectl - Install ##
# Add kubectl's official GPG key
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
# Add k8s's repository (Once the bionic repo is available change this to "deb https://apt.kubernetes.io/ kubernetes-bionic main")
add-apt-repository -y \
    "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt update
# Install latest kubectl
apt install -y kubectl
# Or a specific version
#apt install -y kubectl=1.11.5-00
# Test the installation
kubectl version
# Create .kube directory and set KUBECONFIG in .profile
mkdir -p /home/$username/.kube
cd /home/$username/.kube
touch config
chown -R $username:$username /home/$username/.kube
cd /home/$username
touch .profile
echo 'export KUBECONFIG="/home/$username/.kube/config"' >> .profile
source .profile
## Configure autocompletion for kubectl
cd /home/$username
echo "source <(kubectl completion bash)" >> .bashrc
source .bashrc


## Helm - Install ##
sudo snap install helm --classic


## SSH-Agent - Install ##
#copy the key from shared folder
cp ~/sharedProjectFolder/key.ppk ~/.ssh
sudo apt-get install -y putty-tools
puttygen ~/.ssh/key.ppk -O private-openssh -o ~/.ssh/id_dsa
puttygen ~/.ssh/key.ppk -O public-openssh -o ~/.ssh/id_dsa.pub
chmod 600 ~/.ssh/id_dsa
chmod 666 ~/.ssh/id_dsa.pub
chmod 666 ~/.ssh/known_hosts
echo "Host 10.43.151.100 gitlab.reisendeninfo.aws.db.de" >> config
echo "ForwardAgent yes" >> config
eval `ssh-agent -s`
ssh-add ~/.ssh/id_dsa


## ZSH Suite - Install ##
sudo apt install -y zsh tmux jq


##Adding Personal User
sudo useradd $username
echo $username:U6aMy0wojraho | sudo chpasswd -e  
sudo mkdir -p /home/$username/.ssh
#cat ubuntu.pub | sudo tee -a /home/ubuntu/.ssh/authorized_keys  
#sudo chmod 600 /home/ubuntu/.ssh/authorized_keys
#sudo chmod 700 /home/ubuntu/.ssh
sudo adduser $username sudo
sudo chown -R $username /home/$username 
sudo su $username


## VSCode - Install ##
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt update
sudo apt install -y code
#install vscode extensions
code --install-extension ms-python.python
code --install-extension ms-vscode.Go
code --install-extension donjayamanne.githistory
code --install-extension erd0s.terraform-autocomplete
code --install-extension huizhou.githd mauve.terraform
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension redhat.vscode-yaml
code --install-extension stayfool.vscode-asciidoc
code --install-extension yzhang.markdown-all-in-one


## Guake - Install ##
sudo apt-get install guake -y

## GUI - Install ## 
apt-get install -y ubuntu-desktop
startx


## Print the success notice
echo -e "\e[32mInstallation completed successfully. The Vagrant box is now ready to use with 'vagrant ssh'\e[39m"
