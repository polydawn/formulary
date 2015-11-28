inputs:
	"/":
		type: "tar"
		hash: "lzcqJKln2_H4TIoizNBCr0qoh8u_Nb_LRwARTZL2RumfbChX031pVl46dcSCG4q3"
		silo: "http+ca://repeatr.s3.amazonaws.com/assets/"
	"/apk":
		type: "tar"
		hash: "vbpcsOxw0Uufhec2XvCpr9hfozvm6B2FV-bu6K4xPyx3mofk6-94hXOMB-NPqf28"
		silo: "http://nl.alpinelinux.org/alpine/v3.2/main/x86_64/apk-tools-static-2.6.3-r0.apk"
	"/apk-known-keys":
		type: "tar"
		hash: "oSYCZSJxa4EMW8YFe5mVoxTn9KPY4FIvx3rnALnV6Cw5sK60CZNci521pFkcw_QP"
		silo: "http://nl.alpinelinux.org/alpine/v3.2/main/x86_64/alpine-keys-1.1-r0.apk"
action:
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x

			mkdir /rhone
			/apk/sbin/apk.static \
				--root /rhone \
				--update-cache \
				--keys-dir /apk-known-keys/etc/apk/keys/ \
				--repository http://nl.alpinelinux.org/alpine/v3.2/main \
				--initdb \
				add alpine-base

			### discard messy bits
			# this one is deterministic, but also a cache that's not relevant to our interests
			rm -rf /rhone/var/cache/apk/
			# this one is ver bad: scripts.tar in particular causes nondet because it has timestamps inside of it
			rm -rf /rhone/lib/apk/db/
outputs:
	"rhone":
		type: "tar"
		mount: "/rhone"
		filters:
			- "uid keep"
			- "gid keep"
		silo: "file+ca://./wares/"
