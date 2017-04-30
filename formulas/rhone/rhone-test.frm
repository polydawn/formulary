### Sanity tester that the 'rhone' image works.
inputs:
	"/":
		type: "tar"
		hash: "yxj0rFk0GI2oAr3RQ52pR4lirg4zv8bd9_qqoeeBtd-uxh7gLUPCFIYLldPpax5M"
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
