### 'rhone' is a minimal but cozy base image snapshot assembled from alpine.
### It contains a bash shell, busybox coreutils, and precious little else.
inputs:
	"/":                {tag: "bootstrap"}
	"/apk":             {tag: "apk"}
	"/apk-known-keys":  {tag: "apk-keys"}
action:
	policy: uidzero
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x

			packages=()
			packages+=("busybox")
			packages+=("bash")

			### Use 'apk' to initialize a new dir with just a handful of packages.
			mkdir rhone
			/apk/sbin/apk.static \
				--root rhone \
				--initdb \
				--update-cache \
				--keys-dir /apk-known-keys/etc/apk/keys/ \
				--repository http://nl.alpinelinux.org/alpine/v3.6/main \
				--no-scripts \
				add "${packages[@]}"

			### discard messy bits
			# this one is deterministic, but also a cache that's not relevant to our interests
			rm -rf rhone/var/cache/apk/ rhone/var/cache/misc/
			# this one is ver bad: scripts.tar in particular causes nondet because it has timestamps inside of it
			rm -rf rhone/lib/apk/db/
			# call me crazy but I find this terminfo db to be excessive
			rm -rf rhone/usr/share/terminfo/
outputs:
	"rhone":
		tag: "rhone-step1"
		type: "tar"
		mount: "/task/rhone"
		filters:
			- "uid keep"
			- "gid keep"
		silo: "file+ca://./wares/"
