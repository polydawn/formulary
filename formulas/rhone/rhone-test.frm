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
			find / | grep -v ^/proc
