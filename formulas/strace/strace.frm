inputs:
	"/":
		type: "tar"
		hash: "aLMH4qK1EdlPDavdhErOs0BPxqO0i6lUaeRE4DuUmnNMxhHtF56gkoeSulvwWNqT"
		silo:
			- "file+ca://./wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
	"/task/src/":
		type: "tar"
		hash: "n6S_yKaFpsRAmfKwkL5_G_FAMyK1zd2au5FZtLaaoRde6PZcVQ7ff715RNNBmcMA"
		silo: "http://downloads.sourceforge.net/project/strace/strace/4.10/strace-4.10.tar.xz"
action:
	policy: governor ## apt-get makes use of chown.
	cwd: "/task"
	command:
		- bash
		- -c
		- |
			set -euo pipefail
			set -x

			apt-get update
			apt-get install -y gcc build-essential

			cd src/*
			CC='gcc -static' \
			./configure || cat config.log
			make
			ldd ./strace || true ## should error because it's static
			mkdir /task/bin
			mv ./strace /task/bin
outputs:
	"/task/bin/":
		type: "tar"
		silo: "file+ca://./wares/"
