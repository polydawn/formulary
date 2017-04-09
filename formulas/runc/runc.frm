inputs:
	"/":
		type: "tar"
		hash: "xK30HS-fszVKemoy2G66_1y5-ppBuuL5_T4CexlIETQojPONkleMi-j2YhvmeYF5"
		silo:
			- "file+ca://./wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
	"/app/go/":
		type: "tar"
		hash: "gi0Kpb-VH3TK0UBX6YmpuKsrMAUlxicPrY2YvXPo9sBQm_NsD_hKrn7pmc95zrmM"
		silo: "https://storage.googleapis.com/golang/go1.8.1.linux-amd64.tar.gz"
	"/task/src/github.com/opencontainers/runc/":
		type: "git"
		hash: "ac50e77bbb440dcab354a328c79754e2502b79ca"
		silo: "https://github.com/opencontainers/runc.git"
action:
	command:
		- "/bin/bash"
		- "-c"
		- |
			set -euo pipefail
			export GOROOT=/app/go/go
			export PATH=$PATH:/app/go/go/bin

			mkdir "/task/output"
			export GOPATH=/task/
			cd "/task/src/github.com/opencontainers/runc/"
			## note: `make static BUILDTAGS=""` is the closest to what we want.
			CGO_ENABLED=1 go build -i \
				-tags "cgo static_build" \
				-ldflags "-w -extldflags -static" \
				-o /task/output/runc .
outputs:
	"executable":
		type: "tar"
		mount: "/task/output"
		silo: "file+ca://./wares/"
