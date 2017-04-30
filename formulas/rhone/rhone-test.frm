### Sanity tester that the 'rhone' image works.
inputs:
	"/":
		type: "tar"
		hash: "4JkW1xaS0LyN-vNMT2y65LxwPwQC674emhW3P6Q6CuK9d6XpCiZtlnToJkgpXXU7"
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
