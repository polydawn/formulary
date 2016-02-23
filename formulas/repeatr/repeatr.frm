inputs:
	"/":
		type: "tar"
		hash: "uJRF46th6rYHt0zt_n3fcDuBfGFVPS6lzRZla5hv6iDoh5DVVzxUTMMzENfPoboL"
		silo: "http+ca://repeatr.s3.amazonaws.com/assets/"
	"/app/go/":
		type: "tar"
		hash: "vbl0TwPjBrjoph65IaWxOy-Yl0MZXtXEDKcxodzY0_-inUDq7rPVTEDvqugYpJAH"
		silo: "https://storage.googleapis.com/golang/go1.5.linux-amd64.tar.gz"
	"/task/repeatr/":
		type: "git"
		hash: "b15dfa15ffb1f70c3655d06ffaeff8a4a9dd1348"
		silo: "https://github.com/polydawn/repeatr.git"
action:
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			export GOROOT=/app/go/go
			export PATH=\$PATH:/app/go/go/bin
			./goad install
	cwd: "/task/repeatr/"
	env:
		"GITCOMMIT": "b15dfa15ffb1f70c3655d06ffaeff8a4a9dd1348"
		"BUILDDATE": "Sat, 24 Oct 2015 23:42:17 -0500"
outputs:
	"executable":
		type: "tar"
		mount: "/task/repeatr/.gopath/bin/"
		silo: "file+ca:///tmp/wares/"
