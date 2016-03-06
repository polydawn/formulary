inputs:
	"/":
		type: "tar"
		hash: "aLMH4qK1EdlPDavdhErOs0BPxqO0i6lUaeRE4DuUmnNMxhHtF56gkoeSulvwWNqT"
		silo:
			- "file+ca://./wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
action:
	policy: governor ## apt-get makes use of chown.
	cwd: "/"
	command:
		- bash
		- -c
		- |
			set -euo pipefail
			set -x

			## Long list of builder packages.
			##  This is chosen somewhat arbitrarily, frankly; what we're doing here is
			##    - *not* hygenic,
			##    - *not* clearly scoped per project,
			##    - and just generally wrong.
			##  The reason it's going in one file here is so we can take one snapshot
			##  of it, and hold onto it, and pray that we can use this as a reasonably
			##  permanent and inoffensive starting point for bootstrapping a better world.
			##  And also, so frankly, as developers, we can not keel over waiting for
			##  the uncaching networked dependency fetchers we're leaning on until then.
			packages=()
			## Normal build-criticals.
			packages+=("make")
			packages+=("gcc")
			packages+=("build-essential")
			## Extended list.  Often downloading tar-packaged sources will
			##  not require these, because the maintainers run them for you.
			packages+=("autoconf")
			packages+=("automake")
			packages+=("m4")
			## Some of the most common header needs.
			##  This list is where things get clearly arbitrary: I am not prepared
			##  to defend these other than to cry "convenience!" and beg forgiveness.
			packages+=("libpcre3-dev")
			packages+=("zlib1g-dev")
			packages+=("libssl-dev")

			apt-get update
			apt-get install -y "${packages[@]}"
outputs:
	"keeper":
		mount: "/"
		type: "tar"
		filters:
			- "uid keep"
			- "gid keep"
		silo: "file+ca://./wares/"
		## Today this results in
		##  "xK30HS-fszVKemoy2G66_1y5-ppBuuL5_T4CexlIETQojPONkleMi-j2YhvmeYF5"
		##  There is no realistic expectation of stability on that.
