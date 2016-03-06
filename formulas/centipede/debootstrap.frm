inputs:
	"/":
		type: "tar"
		hash: "aLMH4qK1EdlPDavdhErOs0BPxqO0i6lUaeRE4DuUmnNMxhHtF56gkoeSulvwWNqT"
		silo:
			- "file+ca://./wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
action:
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x
			echo "nameserver 8.8.8.8" > /etc/resolv.conf
			time apt-get update
			time apt-get install -y debootstrap debian-archive-keyring # why is this not a required
			# --include build-essential,gawk \
			# --exclude dmsetup,systemd,systemd-sysv,udev \
			debootstrap \
				--include build-essential,gawk \
				stable /task/output
			# do some cleanup
			chroot /task/output
			echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
			apt-get autoremove -y
			apt-get clean -y
			rm -rf /var/lib/apt/lists
			rm -rf /var/cache
outputs:
	"/task/output":
		type: "tar"
		filters:
			- "uid keep"
			- "gid keep"
		silo: "file+ca://./wares/"
