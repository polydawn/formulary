inputs:
	"/":
		type: "tar"
		hash: "fk8AVtKp18fqSskN3SjtR2BipSENOezvNj4MHL4vkyi3yNhZrUqsqzMFgAIC8hGW"
		silo: "file+ca://./wares"
	"/task/src/gmp":
		type: "tar"
		hash: "vFbHn-XDgPRKI2j6aYXonaviCd-TBdaH3GdvyC-Tj04Ys0LTc_bqlBgERe5Gmllu"
		silo: "https://ftp.gnu.org/gnu/gmp/gmp-5.0.2.tar.bz2"
action:
	cwd: "/task"
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x

			/task/src/gmp/gmp-5.0.2/configure \
				--prefix=/task/target/fuck \
				--enable-cxx

			make -j8

			ls -la
			find /task/target
			cd /task/target
			grep -ar fuck

outputs:
	"gmp":
		type: "tar"
		mount: "/task/target"
		silo: "file+ca://./wares"
