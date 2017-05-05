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

			### Symlink Alpine's 'ld' to the usual location for this.
			###  '/lib64/ld-linux-x86-64.so.2' is a blessed string embedded in almost
			###   every linux binary you're likely to see in the wild.
			mkdir /lib64
			ln -s /lib/ld-musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

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
