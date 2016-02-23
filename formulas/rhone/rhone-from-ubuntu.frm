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
	## Regretfully, run as uid=0 with significant capabilities.
	## `apk` produces substantal amounts of errors otherwise.
	##
	## In detail:
	##  - `apk` run as a routine non-zero-uid will manifest *most* of
	##    the files correctly, but emit large volumes of complaints about
	##    setting ownership from most of the packages.
	##  - `apk` run with with uid=0 and min caps fares better, but still
	##    hits issues in the post install scripts:
	##      >    (29/30) Installing busybox (1.23.2-r0)
	##      >    Executing busybox-1.23.2-r0.post-install
	##      >    ERROR: busybox-1.23.2-r0.post-install: script exited with error 1
	##      >    (30/30) Installing gawk (4.1.2-r0)
	##      >    Executing busybox-1.23.2-r0.trigger
	##      >    ERROR: busybox-1.23.2-r0.trigger: script exited with error 1
	##    Haven't yet diagnosed details of what these scripts are requiring.
	## - `apk` run with 'governor' mode *almost* gets there -- and exits with success(!!)
	##    ... and yet is subtly wrong: it needs CAP_MKNOD for one... file: '/dev/null'.
	## So, this requires copious privs.
	## It's *really* a bummer that mknod doesn't have reasonably fine-grained
	## privs to separate the obviously safe from dubiously unsafe modes.
	policy: sysad
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x

			packages=()
			packages+=("busybox")  # mvp
			packages+=("bash")     # mvp
			packages+=("gcc")      # compiler
			packages+=("make")     # build-dep gcc
			packages+=("gawk")     # build-dep gcc
			packages+=("build-base")  # idk

			mkdir /rhone
			/apk/sbin/apk.static \
				--root /rhone \
				--update-cache \
				--keys-dir /apk-known-keys/etc/apk/keys/ \
				--repository http://nl.alpinelinux.org/alpine/v3.2/main \
				--initdb \
				add "${packages[@]}"

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
