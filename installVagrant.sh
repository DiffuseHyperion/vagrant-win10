#!/bin/bash
# most code copied from https://medium.com/axon-technologies/installing-a-windows-virtual-machine-in-a-linux-docker-container-c78e4c3f9ba1
if [ "$EUID" -ne 0 ]
  then echo "Please run as root!"
  exit
fi

echo "installVagrant.sh successfully run!"
echo "Where should vagrant be located? Ideally, it should be in /home/(username)/vagrant, to avoid permission issues. If you decide not too, you will need to chown the files yourself."
read dir
echo Storing files at $dir.

# vagrant and libvirt installation
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
mv ~/.vagrant.d $dir/vagrant
vagrant plugin install vagrant-libvirt

# vagrantfile
mkdir win10
cd win10
curl -O https://raw.githubusercontent.com/DiffuseHyperion/vagrant-win10/main/Vagrantfile

# libvirt default storage pool
cd ..
mkdir libvirt
cd libvirt
mkdir images
virsh pool-define-as --name default --type dir --target $dir/libvirt/images/

# export vagrant's file location
echo export VAGRANT_HOME=$dir/vagrant >> ~/.bash_profile
echo export VAGRANT_DOTFILE_PATH=vagrant >> ~/.bash_profile
source ~/.bash_profile

echo "Install complete! You may need to run the following command:"
echo "vagrant plugin install vagrant-libvirt"
echo Afterwards, cd into $dir/win10 and do:
echo "VAGRANT_DEFAULT_PROVIDER=libvirt vagrant up"
echo "The disk size might be set to 50 GB, even if Vagrantfile says otherwise. Windows 10's partition is very likely to not occupy the disk fully. Extend Window's partition to fix this.

