inputs:
	"/":
		type: "tar"
		hash: "47d8y5bXNQFVTdpwPQfotAQ7zGDSFPYpmXtNH3gQMuteYq09-18m-VsIT5bttMxw"
		silo:
			- "file+ca://./wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
action:
	policy: governor
	command:
		- "/bin/bash"
		- "-c"
		- |
			set -euo pipefail
			set -x
			time apt-get update
			time apt-get dist-upgrade
outputs:
	"/":
		type: "tar"
		filters:
			- "uid keep"
			- "gid keep"
		silo: "file+ca://./wares/"
