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
			debootstrapOpts=()
			debootstrapOpts+=("--arch=amd64") ## redundant, but just to be clear.
			debootstrapOpts+=("--variant=minbase") ## *sounds* like min, but actually still includes gcc (twice!)
			#debootstrapOpts+=("--print-debs") ## i think it would be nice to list what you're doing first but this also stops it from doing anything further.
			debootstrapOpts+=("--download-only") ## alt: try '--make-tarball=' but then we have to hilariously untar it.
			debootstrapExclude=()
			debootstrapExclude+=("gcc-5-base") ## honestly don't think I should have to say this.
			debootstrapExclude+=("gcc-6-base") ## honestly don't think I should have to say this.
			debootstrapExclude+=("libsystemd0") ## so wrong.
			debootstrap \
				"${debootstrapOpts[@]}" \
				--exclude="$(IFS=',' ; echo "${debootstrapExclude[*]}")" \
				--keep-debootstrap-dir \
				unstable \
				/task/output
			find /task/output
			exit

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
					rm -rf /var/cache/{apt,debconf,ldconfig}
					# truncate so as not to lose the file's ownership.
					truncate --size=0 /var/log/alternatives.log /var/log/dpkg.log /var/log/apt/* || true
					# only remove files for the same reason (the 'partial' directory has odd bits, and removing it causes additional kerfuffle later).
					find /var/lib/apt/lists -type f | xargs rm
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
