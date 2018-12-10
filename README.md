# Reproduction of LXC library and libcontainer

When a process uses libcontainer to spin up a container but is linked to LXC, the newly created container may not have its cgroups properly setup.  This repository demonstrate the behavior and proposes few fixes.  This bug causes some nomad tests to fail in TravisCI, namely tests that use cgroup process tracking to shutdown tasks.

The repository has two directories:

* [`plain-c`](./plain-c) is a C program that emits the cgroup of the process to demonstrate lxc modifying cgroups.
* [`libcontainer`](./libcontainer) is a Go program that spins up a libcontainer process and inspects the cgroups inside container.

You can reproduce the problem by running `sudo test.sh` in each of the directories.  The test scripts would compile and run a process that emits the effective cgroup without linking to LXC first, then once again with LXC linked.

[`plain-c/output.txt`](./plain-c/output.txt) has the output of plain-c test case and shows that when running with LXC, all cgroups subsystems get set to root cgroup consistently.

[`libcontainer/output.txt`](./libcontainer/output.txt) has a sample output of libcontainer test case.  When compiled without LXC, the cgroups inside the cgroup container consistently get set; but when running with liblxc, the cgroup results vary from run to run with only some cgroup subsystems getting assigned to the expected values.

It's worth noting that in both cases, linking against liblxc is sufficient to trigger the issue.  No calls to liblxc library is required.

## Why?! How?!

`liblxc` has an library initializer, [`cgroup_ops_init`](https://github.com/lxc/lxc/blob/stable-2.1/src/lxc/cgroups/cgroup.c#L40-L57) that is called when library is loaded at runtime; when cgmanager is available, it calls `cgm_ops_init`.  [`cg_ops_init`](https://github.com/lxc/lxc/blob/stable-2.1/src/lxc/cgroups/cgmanager.c#L1443-L1447) forces process to escape cgroup to root cgroup if process owner is root.

In `plain-c`, the effect is straightforward, as all subsystems get set to root cgroup as identified above.

In `libcontainer` case, it's a bit more complicated.  `libcontainer` starts a couple of intermediary processes to construct the container.  With a bit of simplification, `libcontainer` library starts a new process (by invoking self binary) that will eventually be container PID 1, configures the cgroups of the new process, and then when new process is properly configured with namepsaces/cgroups/etc it `exec`'s the container Args as set by initial command.  When running against liblxc, liblxc attempts to set self cgroup to root cgroup, while libcontainer in original process configures the child process cgroup!  The race results into different configurations at different runs.

## Why does it matter for Nomad?!

The obvious result is when running Nomad that's compiled with LXC support, exec and java tasks may not have proper resource isolation and may use more than they need.

The more subtle case is shutting down processes!  When killing the process, we may rely on freezer or devices cgroup tracking of task container processes.  Thus, we may not properly kill the processes.  It may manifest as leaked processes, some CI tests report timeouts, or block indefinitely.

Docker and rkt drivers are not affected; as the rkt and Docker daemon manage their own processes and aren't linked to LXC.  When docker/rkt creates a task container, it can configure it without liblxc interference.

Mahmood hasn't tested impact on Nomad pre-0.9, as those versions did not use libcontainer.  Depending on how nomad initializes exec/java, it may be vulnerable but we never noticed.

## Solutions?

We have few solutions in Nomad:

* Use Nomad 9.0 Plugins: we can distribute LXC as an external plugin driver.  This ensures executors self-invocation will not be corrupted by liblxc interactions.
* Use `lxc` tools instead of linking to the library.  `lxc` library is pain: it requires publishing special binaries, constrains development on it to Linux boxes with lxc installed.  Using `lxc` commands makes it easier to develop and publish a single binary without losing much power, as the lxc CLIs are thin wrappers around the library.

### Details

Mahmood tested this only on Ubuntu 14.04 and liblxc 1.x and 2.x, the configuration used in Nomad TravisCI setup.  I have not tested against recent versions of Ubuntu.


## How to reproduce!

Run the following:

```
# on host
vagrant up
vagrant ssh

# inside VM
cd ~/go/src/github.com/notnoop/libcontainer-lxc-bug/plain-c/
sudo ./test.sh

cd ~/go/src/github.com/notnoop/libcontainer-lxc-bug/libcontainer/
sudo ./test.sh
```