### Sanity tester that the 'rhone' image works.
inputs:
	"/":
		type: "tar"
		hash: "Fr6-wgGLi9i1MZroHpwpd8tW-alGrI5FRkWK_KRT90NdKMIKdShG_1aAbLSvXr9b"
		silo:
			- "file+ca://./wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
action:
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x

			echo hello world
			find /
