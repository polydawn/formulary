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
			debootstrap \
				unstable /task/output
			## now prance harder, inside the newstrap
			chroot /task/output bash -c "$(cat <<EOF
				set -euo pipefail
				set -x
				cat /etc/os-release
				
				# can you please not install mono, a haskel compiler, and a fucking jdk on your way to diffoscope, which uses none of those things?
				echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf
				echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf
				echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
				
				# finally get diffoscope.  it wasn't available as an `--include` at debootstrap time.
				time apt-get update
				time apt-get install -y diffoscope
				
				# be less diskwastey
				apt-get autoremove -y
				apt-get clean -y
				rm -rf /var/lib/apt/lists
				rm -rf /var/cache
			EOF
			)"
outputs:
	"/task/output":
		type: "tar"
		filters:
			- "uid keep"
			- "gid keep"
		silo: "file+ca://./wares/"
