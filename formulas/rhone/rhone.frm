### 'rhone' is a minimal but cozy base image snapshot assembled from alpine.
### It contains a bash shell, busybox coreutils, and precious little else.
inputs:
	"/":
		type: "tar"
		hash: "aLMH4qK1EdlPDavdhErOs0BPxqO0i6lUaeRE4DuUmnNMxhHtF56gkoeSulvwWNqT"
		silo:
			- "file+ca://./wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
	"/apk":
		type: "tar"
		hash: "QzL5_CplD_vt1QXRZwlVFrhKZKNP3q0oStYwJSaOu8pxNfkwiiGks-wNLWksvCM1"
		silo: "http://nl.alpinelinux.org/alpine/v3.6/main/x86_64/apk-tools-static-2.7.1-r0.apk"
	"/apk-known-keys":
		type: "tar"
		hash: "mPujwdqo-0ZyaZ44syjhXf_o9MSlxvxCfJL3i1qq09GWl6ItfsN9xSxPjuOHZahA"
		silo: "http://nl.alpinelinux.org/alpine/v3.6/main/x86_64/alpine-keys-2.1-r1.apk"
action:
	policy: governor
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x

			packages=()
			packages+=("busybox")
			#packages+=("coreutils")
			packages+=("bash")

			mkdir rhone
			/apk/sbin/apk.static \
				--root rhone \
				--initdb \
				--update-cache \
				--keys-dir /apk-known-keys/etc/apk/keys/ \
				--repository http://nl.alpinelinux.org/alpine/v3.6/main \
				add "${packages[@]}"
			# note: apk has this neat '--no-scripts' flag, and with it, this would actually run with policy=uidzero.
			#  however, no-scripts for busybox, heh, no.  result is not operational.

			### discard messy bits
			# this one is deterministic, but also a cache that's not relevant to our interests
			rm -rf rhone/var/cache/apk/
			# this one is ver bad: scripts.tar in particular causes nondet because it has timestamps inside of it
			rm -rf rhone/lib/apk/db/
outputs:
	"rhone":
		type: "tar"
		mount: "/task/rhone"
		filters:
			- "uid keep"
			- "gid keep"
		silo: "file+ca://./wares/"
