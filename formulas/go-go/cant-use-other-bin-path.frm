inputs:
	"/":
		type: "tar"
		hash: "aLMH4qK1EdlPDavdhErOs0BPxqO0i6lUaeRE4DuUmnNMxhHtF56gkoeSulvwWNqT"
		silo:
			- "file+ca://./wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
	"/app/go/":
		type: "tar"
		hash: "vbl0TwPjBrjoph65IaWxOy-Yl0MZXtXEDKcxodzY0_-inUDq7rPVTEDvqugYpJAH"
		silo: "https://storage.googleapis.com/golang/go1.5.linux-amd64.tar.gz"
action:
	env:
		"PATH": "/usr/bin/:/bin/" #:/app/go/go/bin/"
		"GOROOT_BOOTSTRAP": "/bootstrap-go/"  # essential
		"GOROOT": "/app/go/go/"               # essential (since we move out the existing go tools)
		"CGO_ENABLED": "0"                    # essential (otherwise a C compiler is required
		"GOROOT_FINAL": "/usr/local/go/"      # pleasantry (try to be like the upstream builds)
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x

			mkdir -p /bootstrap-go/
			mv /app/go/go/bin /bootstrap-go # because the go build builds over itself
			cd /app/go/go/src # because you're required to have this cwd when making
			./make.bash --no-clean
outputs:
	"/app/go/go/bin/":
		type: "dir"
		silo: "file+ca://./wares/"
