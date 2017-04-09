inputs:
	"/":
		type: "tar"
		hash: "aLMH4qK1EdlPDavdhErOs0BPxqO0i6lUaeRE4DuUmnNMxhHtF56gkoeSulvwWNqT"
		silo:
			- "file+ca://./wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
	"synapse":
		type: "git"
		hash: "a8945d24d10e74c9011a2ba934799a201d19e12c" # refs/tags/v0.10.1-rc1
		silo: "https://github.com/matrix-org/synapse.git"
		mount: "/synapse"
action:
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x
			## NOTE: though this container starts out as root (for apt-get's sake, mostly),
			##  we spend a lot of time dropping down to uid=1000.
			## Many of the systems we're dealing with download code with no end-to-end integrity
			##  checks at all, which is quite frankly begging to be rooted and so we won't do it.

			## Add unpriviledged usernames.
			##  One would wish we could just use the uid without naming it, but "KeyError: 'getpwuid(): uid not found: 1000'" from pip.  Sigh.
			groupadd "pants" --gid=1000 --force
			useradd  "pants" --gid=1000 --uid=1000 --no-create-home

			## Get some deps from apt.
			## But first, apt is wildly over-inclusive by default.  Configure it not to pull in unnecessary... stuff.
			export DEBIAN_FRONTEND=noninteractive
			echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf
			echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf
			echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
			## Now apt.
			## This will take a long time.
			## Also one really questions why we need build-essential?  that seems unreasonable
			time apt-get update
			time apt-get install -y build-essential python2.7-dev libffi-dev \
				python-pip python-setuptools sqlite3 \
				libssl-dev python-virtualenv libjpeg-dev

			## pip pip
			mkdir -p /task/pip
			chown 1000:1000 /task/pip
			sudo -u \#1000 -g \#1000 bash <<EOF
				time pip install --target=/task/pip --upgrade pip
			EOF


			## wot
			mkdir -p /synapse-deps
			chown 1000:1000 /synapse-deps
			sudo -u \#1000 -g \#1000 bash <<EOF
				#export HOME=$PWD/stage
				#virtualenv -p python2.7 stage/synapse/.virtualenv
				#source stage/synapse/.virtualenv/bin/activate
				ls -la /synapse
				time pip install --target=/synapse-deps --process-dependency-links /synapse
			EOF
outputs:
	"synapse-deps":
		type: "dir"
		mount: "/synapse-deps"
		silo: "./tmp/synapse-deps"
	"wtf pip":
		type: "dir"
		mount: "/task/pip"
		silo: "./tmp/pip"
