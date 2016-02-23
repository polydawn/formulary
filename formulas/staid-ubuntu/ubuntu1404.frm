inputs:
	"/":
		# Ubuntu 14.04.4
		# Notes:
		# - relevant upstream changelist: https://wiki.ubuntu.com/TrustyTahr/ReleaseNotes/ChangeSummary/14.04.4
		# - yes, ubuntu 14.04.4 includes the fix for the nigh-world-ending libc bug (CVE-2015-7547) you're worried about: http://www.ubuntu.com/usn/usn-2900-1/
		# - size: about 208mb unpacked; 63M as the gz over the network.
		type: "tar"
		hash: "llx9Hykg6ZwL168g7HldRgZRGa4-qdEXvVv-2ZEwNE6NAonvrC5107S-Tae9B_mW"
		silo: "http://cdimage.ubuntu.com/ubuntu-core/releases/trusty/release/ubuntu-core-14.04.4-core-amd64.tar.gz"
action:
	policy: governor ## apt-get makes use of chown.
	cwd: "/"
	command:
		- bash
		- -c
		- |
			set -euo pipefail
			set -x

			## Provide a variety of configurations to apt&friends.
			##  What's appropriate for a container is different (and generally less work!) than for a full host.
			(
				## Don't install "recommends" or "suggests".
				## These lists are often sprawling.
				## Whitelist your needs properly.
				echo 'Apt::Install-Recommends "0";'                 >> /etc/apt/apt.conf.d/80container-norecommends
				echo 'Apt::Install-Suggests "0";'                   >> /etc/apt/apt.conf.d/80container-norecommends
				echo 'Apt::AutoRemove::SuggestsImportant "false";'  >> /etc/apt/apt.conf.d/80container-norecommends

				## Don't attempt to launch services during install.
				echo -ne '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d
				chmod +x /usr/sbin/policy-rc.d

				## Speed up operations by using "unsafe" I/O.
				##  Since we manage transactions above the level of an
				##  entire container, there's no real need for this safety.
				echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/container-speedup

				## Configure apt to clear its own caches and logs after every run.
				##  It would be poor to snapshot out of date caches and lists, and also they're
				##  just plain too hefty to want to lug around; the logs are unneeded and
				##  contain timestamps which instantly break reproducibility.
				## One result of this to watch out for is that as a result of the 'nolists' rule,
				##  you can't `apt-get install` multiple times in a row.
				echo 'DPkg::Post-Invoke { "rm -rf /var/cache/apt/ || true"; };'         >> /etc/apt/apt.conf.d/80container-nocache
				echo 'Apt::Update::Post-Invoke { "rm -rf /var/cache/apt/ || true"; };'  >> /etc/apt/apt.conf.d/80container-nocache
				echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";'             >> /etc/apt/apt.conf.d/80container-nocache
				## When cleaning up logs, just truncate; don't remove.  Keeps permissions.
				##  This means subsequent containers using apt won't need policy=governor just so apt can try to chown these files to group=adm.
				echo 'DPkg::Post-Invoke { "truncate --size=0 /var/log/alternatives.log /var/log/dpkg.log /var/log/apt/* || true"; };' >> /etc/apt/apt.conf.d/80container-nolog
				echo 'DPkg::Post-Invoke { "rm -rf /var/lib/apt/lists/ || true"; };' >> /etc/apt/apt.conf.d/80container-nolists

				## Languages are nice but are significant heft; if you want 'em, enable 'em.
				echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/80container-languages

				## Containers don't need kernels.
				rm -f /etc/apt/apt.conf.d/01autoremove-kernels
			)

			## Enable the 'universe' set of packages.
			sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list

			## Configure a default DNS service.
			##  Since we don't launch any regular daemons, autodetect does
			##   not become available, so something is better than nothing.
			chmod 644 /etc/resolv.conf
			echo "nameserver 8.8.8.8" > /etc/resolv.conf

			## Add a few things that are just too useful to miss.
			##  We actually *don't need to* `apt-get update` here: the image came bundled with lists!
			##  This means we are intentionally not getting additional updates since the release date of this base image, yes.
			packages=()
			packages+=("curl")
			packages+=("wget")
			packages+=("ca-certificates")
			packages+=("make")
			apt-get install -y "${packages[@]}"

			## TODO: Manual whitelist of reasonable packages to keep in a container.
			##  (e.g. we don't need lots of things for, say, wifi drivers, so let's not waste disk.)
			##   (The `dpkg-query -Wf '${Package}\n'` command would likely help with this.)

			## Meanwhile, beg for autoremove to get rid of a few things.
			## (Has no effect, purely hope-fueled.)
			apt-get autoremove

			## And remove this "cache" file.  I don't know what it does,
			## but it updates nondeterministically after apt installs libraries
			## and appears to serve approximately no useful purpose.
			rm /var/cache/ldconfig/aux-cache

			## Checklist!
			##  These are all things we want available out-of-box.
			##  (Depending on your philosophical view of containers, some of these
			##  are honestly dubious: for example, if you're using our "routine"
			##  policy, "adduser" isn't exactly in your lexicon; and if you're avoiding
			##  network dependencies at build/runtime, you aren't likely interested
			##  in having "wget" and "curl" at the ready.
			##  But this image is meant for broad-spectrum appeal and use in
			##  legacy situations, so along they come.)
			(
				which bash
				which curl
				which wget
				which adduser
				which make
				which apt-get
			)
outputs:
	"keeper":
		mount: "/"
		type: "tar"
		filters:
			- "uid keep"
			- "gid keep"
		silo: "file+ca://./wares/"
		## expected result:
		##   hash: "d24vKLQ2E0jSK41DIgNYJtevkvPDjABdvoq1B3PbN8NlWuJNMG-OWhBlpKWmcIus"
		##   ... and about 63M as a gz; no significant increase in size from the added stuff.
	"debug":
		## export again as dir because I'm lazy and diffing on these.
		mount: "/"
		type: "dir"
		filters:
			- "uid keep"
			- "gid keep"
		silo: "file+ca://./debug/"
