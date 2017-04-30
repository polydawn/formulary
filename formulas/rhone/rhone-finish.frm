### 'rhone' is a minimal but cozy base image snapshot assembled from alpine.
### It contains a bash shell, busybox coreutils, and precious little else.
inputs:
	"/":  {tag: "rhone-step1"}
action:
	policy: uidzero
	cradle: false
	cwd: /
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x

			### Finish busybox install.  (apk scripts usually do this, but we disabled
			###  those and do this step manually ourselves for permissions reasons.)
			/bin/busybox --install -s

			### Finish bash install.
			add-shell '/bin/bash'

			### Configure a default DNS service (something is better than nothing).
			echo "nameserver 8.8.8.8" > /etc/resolv.conf
outputs:
	"rhone":
		tag: "rhone"
		type: "tar"
		mount: "/"
		filters:
			- "uid keep"
			- "gid keep"
		silo: "file+ca://./wares/"
