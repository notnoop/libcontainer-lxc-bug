# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "bento/ubuntu-14.04"

  config.vm.synced_folder '.',
          '/home/vagrant/go/src/github.com/notnoop/libcontainer-lxc-bug'

  config.vm.provision "shell", inline: <<-SHELL
    set -ex

    chown vagrant:vagrant /home/vagrant/go /home/vagrant/go/src /home/vagrant/go/src/github.com /home/vagrant/go/src/github.com/notnoop

    # install LXC and cgroups
    apt-get update || true
    apt-get install -y \
        liblxc1 lxc-dev lxc cgroup-lite \
        build-essential pkg-config git

    # install go
    curl --fail -sSL -o /tmp/go.tar.gz \
      https://dl.google.com/go/go1.11.2.linux-amd64.tar.gz

    tar -C /usr/local -xzf /tmp/go.tar.gz
    rm -rf /tmp/go.tar.gz
    ln -s /usr/local/go/bin/go /usr/bin/go

    # prepare alpine rootfs
    rm -rf /tmp/alpine
    mkdir -p /tmp/alpine/rootfs
    curl --fail -sSL -o /tmp/alpine/alpine-minirootf.tar.gz \
        http://dl-cdn.alpinelinux.org/alpine/v3.8/releases/x86_64/alpine-minirootfs-3.8.1-x86_64.tar.gz
    echo 'ad753d802048fa902e4d8b35cc53656de8ed0e6d082246089a11a86014b0f1a5  /tmp/alpine/alpine-minirootf.tar.gz' | sha256sum -c
    tar -xz -C /tmp/alpine/rootfs -f /tmp/alpine/alpine-minirootf.tar.gz
    
  SHELL
end
