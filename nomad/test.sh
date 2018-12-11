#!/bin/bash

set -e

go get -tags lxc -v github.com/hashicorp/nomad

export PATH=/home/vagrant/go/bin:$PATH

start_nomad() {
	nomad agent -dev >nomad.log 2>&1
}

is_nomad_up() {
	# check if exec driver is healthy
	nomad node status -self 2>/dev/null |grep -q ',exec,'
}

echo starting nomad
is_nomad_up || start_nomad &

echo -n "waiting for nomad to be ready: "

while ! is_nomad_up
do
	sleep 1
	echo -n .
done

echo " ready"

# clear the job is it's already there
nomad job stop --purge example || true

nomad job run ./example.nomad

sleep 10

is_job_done() {
	nomad job status example |grep -A1 Status |grep -q complete
}

echo -n "waiting for nomad job to complete: "
while ! is_job_done
do
	sleep 1
	echo -n .
done

echo " ready"

nomad alloc logs --job example
