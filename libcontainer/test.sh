#!/bin/bash

go build -o libcontainer-without-lxc .
go build -o libcontainer-with-lxc -tags lxc .

echo RUNNING WITHOUT LXC LINKED
sudo ./libcontainer-without-lxc /tmp/alpine/rootfs/

echo
echo RUNNING WITH LXC_LINKED
echo running three times because it is a race

echo
echo RUN 1.
sudo ./libcontainer-with-lxc /tmp/alpine/rootfs/

echo
echo RUN 2.
sudo ./libcontainer-with-lxc /tmp/alpine/rootfs/

echo
echo RUN 3.
sudo ./libcontainer-with-lxc /tmp/alpine/rootfs/

echo
echo RUN 4.
sudo ./libcontainer-with-lxc /tmp/alpine/rootfs/
