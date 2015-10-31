inputs:
	"/":
		type: "tar"
		hash: "lzcqJKln2_H4TIoizNBCr0qoh8u_Nb_LRwARTZL2RumfbChX031pVl46dcSCG4q3"
		silo: "http+ca://repeatr.s3.amazonaws.com/assets/"
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
			time apt-get install -y debootstrap
			# --include build-essential,gawk \
			# --exclude dmsetup,systemd,systemd-sysv,udev \
			debootstrap \
				--variant=minbase \
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
