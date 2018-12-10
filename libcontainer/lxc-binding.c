// +build linux,cgo,lxc

#include <stdio.h>

#include <lxc/lxccontainer.h>


void function_that_never_gets_called() {
    printf("I should not have been called\n");

    lxc_attach_run_command(NULL);
}