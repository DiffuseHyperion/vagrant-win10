#!/bin/bash
# most code copied from https://medium.com/axon-technologies/installing-a-windows-virtual-machine-in-a-linux-docker-container-c78e4c3f9ba1
if [ "$EUID" -ne 0 ]
  then echo Please run as root!
  exit
fi

echo installVagrant.sh successfully run!
echo Where should vagrant be located?
read dir
echo Storing files at $dir.

cd $dir
apt-get update -y
apt-get install -y qemu-kvm libvirt-daemon-system libvirt-dev
chown root:kvm /dev/kvm
service libvirtd start
service virtlogd start
apt-get install -y linux-image-$(uname -r)
apt-get install curl -y
apt-get install net-tools -y
apt-get install jq -y
apt-get install build-essential -y
vagrant_latest_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/vagrant  | jq -r -M '.current_version')
echo $vagrant_latest_version
curl -O https://releases.hashicorp.com/vagrant/$(echo $vagrant_latest_version)/vagrant_$(echo $vagrant_latest_version)_x86_64.deb
dpkg -i vagrant_$(echo $vagrant_latest_version)_x86_64.deb

chown diffusehyperion:diffusehyperion -R $dir/.vagrant.d

mkdir win10
cd win10
curl -O https://raw.githubusercontent.com/DiffuseHyperion/vagrant-win10/main/Vagrantfile

cd ..
mkdir libvirt
cd libvirt
mkdir images
virsh pool-define-as --name default --type dir --target $dir/libvirt/images/

echo export VAGRANT_HOME=$dir/.vagrant.d >> /etc/environment
echo export VAGRANT_DOTFILE_PATH=$dir/.vagrant.d >> /etc/environment

echo Install complete! You may need to run the following command:
echo vagrant plugin install vagrant-libvirt

