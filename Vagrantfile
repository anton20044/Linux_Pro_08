# -*- mode: ruby -*-
# vim: set ft=ruby :


MACHINES = {
  :rpm => {
        :box_name => "alma",
        :box_version => "0",
#	:provision => "create_repo.sh",
	:provision => "make_nginx.sh"
    }        
}


Vagrant.configure("2") do |config|


  MACHINES.each do |boxname, boxconfig|


      config.vm.define boxname do |box|


        box.vm.box = boxconfig[:box_name]
        box.vm.box_version = boxconfig[:box_version]


        box.vm.host_name = "rpm"
	box.vm.network "private_network", ip: "192.168.56.15"


        box.vm.provider :virtualbox do |vb|
              vb.customize ["modifyvm", :id, "--memory", "8192"]
       # end
      end
        box.vm.provision "shell", inline: <<-SHELL
           yum update
	   yum install wget rpmdevtools rpm-build createrepo yum-utils cmake gcc gcc-c++ git nano libibverbs-utils epel-release perl-generators libxslt-devel gd-devel perl-ExtUtils-Embed  -y
      SHELL
      box.vm.provision "shell", path: boxconfig[:provision]
    end
  end
end
