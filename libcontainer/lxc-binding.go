// +build linux,cgo,lxc

package main

// #cgo pkg-config: lxc
// #cgo LDFLAGS: -llxc -lutil
import "C"
