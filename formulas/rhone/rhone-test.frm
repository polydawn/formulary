### Sanity tester that the 'rhone' image works.
inputs:
	"/":  {tag: "rhone"}
action:
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x

			echo hello world
			find {/usr,/bin,/lib} -type f -perm +0111

			ls -lah /etc/apk
			head -n9999 /etc/apk/*
