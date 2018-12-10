#!/bin/bash

export CGROUP_NAME="test-lxc/plainc-lxc-$(date +%s)"
export SELF_PID="$$"

setup_cgroup() {
  # create all cgroups and move this task to them
  for p in $(ls /sys/fs/cgroup/*/cgroup.procs)
  do
    CGROUP_PATH="$(echo $p | sed "s|/cgroup.procs|/${CGROUP_NAME}|g")"
    mkdir -p ${CGROUP_PATH}
    echo ${SELF_PID} > ${CGROUP_PATH}/cgroup.procs
  done
}

setup_cgroup

echo RUNNING WITHOUT LINKING LXC
gcc -o hello-nolxc ./main.c $(pkg-config --libs --cflags lxc)
./hello-nolxc

echo
echo RUNNING WITH LINKING LXC
gcc -o hello-lxc ./main.c -DLINK_LXC $(pkg-config --libs --cflags lxc)
./hello-lxc
