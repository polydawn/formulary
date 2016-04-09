inputs:
	"/":
		type: "tar"
		hash: "xK30HS-fszVKemoy2G66_1y5-ppBuuL5_T4CexlIETQojPONkleMi-j2YhvmeYF5"
		silo:
			- "file+ca://./wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
	"/app/go/":
		type: "tar"
		hash: "vbl0TwPjBrjoph65IaWxOy-Yl0MZXtXEDKcxodzY0_-inUDq7rPVTEDvqugYpJAH"
		silo: "https://storage.googleapis.com/golang/go1.5.linux-amd64.tar.gz"
	"/task/":
		type: "git"
		hash: "6c36d666a1623d57f0d7df98b573245256c47a95"
		silo: "https://github.com/opencontainers/runc.git"
action:
	command:
		- "/bin/bash"
		- "-c"
		- |
			set -euo pipefail
			export GOROOT=/app/go/go
			export PATH=$PATH:/app/go/go/bin
			export GOPATH=$PWD/.gopath
			this=github.com/opencontainers/runc
			mkdir -p $GOPATH/src/$(dirname $this)
			ln -s ../../../../ $GOPATH/src/$this
			#BUILDTAGS="" make -e localtest all
			export GOPATH=$PWD/Godeps/_workspace:$GOPATH
			mkdir /task/output
			mkdir /task/output/bin
			go build -o /task/output/bin/runc
			go test -v ./...
outputs:
	"executable":
		type: "tar"
		mount: "/task/output"
		silo: "file+ca://./wares/"
