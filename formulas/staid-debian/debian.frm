inputs:
	"/":
		type: "tar"
		hash: "aLMH4qK1EdlPDavdhErOs0BPxqO0i6lUaeRE4DuUmnNMxhHtF56gkoeSulvwWNqT"
		silo:
			- "file+ca://./wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
action:
	policy: sysad ## needed for debootstrap (it uses mknod).
	command:
		- "/bin/bash"
		- "-c"
		- |
			set -euo pipefail
			set -x

			## Get debootstrap.
			time apt-get update
			time apt-get install -y debootstrap

			## Run debootstrap.
			debootstrap \
				--arch=amd64 --variant=minbase \
				unstable \
				/task/output

			## Chroot into the debootstrap'd path, and sanitize.
			chroot /task/output bash -c "$(cat <<EOF
				set -euo pipefail
				set -x
				cat /etc/os-release

				## Don't install "recommends" or "suggests".
				## These lists are often sprawling.
				## Whitelist your needs properly.
				echo 'APT::Install-Recommends "0";'                  > /etc/apt/apt.conf.d/80norecommends
				echo 'APT::Install-Suggests "0";'                   >> /etc/apt/apt.conf.d/80norecommends
				echo 'Apt::AutoRemove::SuggestsImportant "false";'  >> /etc/apt/apt.conf.d/80norecommends
				echo 'Acquire::Languages "none";'                   >> /etc/apt/apt.conf.d/80norecommends

				## Don't attempt to launch services during install.
				echo -ne '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d
				chmod +x /usr/sbin/policy-rc.d

				## Speed up operations by using "unsafe" I/O.
				##  Since we manage transactions above the level of an
				##  entire container, there's no real need for this safety.
				echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/unsafe-io

				## Fabricate a script for cleaning up apt state that's inappropriate
				##  to haul around in a containerized universe.
				## We'll call it immediately, but also keep it on hand, in case
				##  later formulas use apt tools again and need the same cleanup.
				cat > /usr/bin/apt-zero <<-EOF2
					apt-get autoremove -y
					apt-get clean -y
					rm -rf /var/lib/apt/lists
					rm -rf /var/cache/{apt,debconf,ldconfig}
					# truncate so as not to lose the file's ownership.
					truncate --size=0 /var/log/alternatives.log /var/log/dpkg.log /var/log/apt/* || true
			EOF2
				chmod +x /usr/bin/apt-zero
				/usr/bin/apt-zero

				## Configure a default DNS service (something is better than nothing).
				chmod 644 /etc/resolv.conf
				echo "nameserver 8.8.8.8" > /etc/resolv.conf
			EOF
			)"
outputs:
	"/task/output":
		type: "tar"
		filters:
			- "uid keep"
			- "gid keep"
		silo: "file+ca://./wares/"
