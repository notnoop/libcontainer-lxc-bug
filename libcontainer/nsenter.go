package main

import (
	"os"
	"runtime"

	"github.com/opencontainers/runc/libcontainer"
	_ "github.com/opencontainers/runc/libcontainer/nsenter"
)

// init is only run on linux and is used when the LibcontainerExecutor starts
// a new process. The libcontainer shim takes over the process, setting up the
// configured isolation and limitions before execve into the user process
func init() {
	if len(os.Args) > 1 && os.Args[1] == "libcontainer-shim" {
		runtime.GOMAXPROCS(1)
		runtime.LockOSThread()
		factory, _ := libcontainer.New("")
		if err := factory.StartInitialization(); err != nil {
			panic(err)
		}
		panic("--this line should have never been executed, congratulations--")
	}
}
