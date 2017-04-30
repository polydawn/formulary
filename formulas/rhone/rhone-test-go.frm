### Sanity tester that the 'rhone' image supports a regular go compiler.
inputs:
	"/":  {tag: "rhone"}
	"/app/go":
		type: "tar"
		hash: "gi0Kpb-VH3TK0UBX6YmpuKsrMAUlxicPrY2YvXPo9sBQm_NsD_hKrn7pmc95zrmM"
		silo: "https://storage.googleapis.com/golang/go1.8.1.linux-amd64.tar"
action:
	env:
		"PATH": "/bin/:/usr/bin/:/app/go/go/bin/"
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x

			ldd `which go`
			go
