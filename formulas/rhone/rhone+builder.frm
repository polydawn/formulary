### 'rhone+builder' adds gcc to the basic 'rhone' image.
### Like the basic image, we're gathering materials using Alpine APK.
inputs:
	"/":                {tag: "rhone"}
	"/task/rhone":      {tag: "rhone"}
	"/apk":             {tag: "apk"}
	"/apk-known-keys":  {tag: "apk-keys"}
action:
	policy: uidzero
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x

			packages=()
			packages+=("gcc")

			### Use 'apk' to stack up some new packages.
			###  (We're running this from the outside again because *we can*,
			###  and it means we continue to be free to not bundle the apk tools.)
			/apk/sbin/apk.static \
				--root rhone \
				--initdb \
				--update-cache \
				--keys-dir /apk-known-keys/etc/apk/keys/ \
				--repository http://nl.alpinelinux.org/alpine/v3.6/main \
				--no-scripts \
				add "${packages[@]}"

			### Discard messy bits.
			# this one is deterministic, but also a cache that's not relevant to our interests
			rm -rf rhone/var/cache/apk/ rhone/var/cache/misc/
			# this one is ver bad: scripts.tar in particular causes nondet because it has timestamps inside of it
			rm -rf rhone/lib/apk/db/
outputs:
	"rhone-builder":
		tag: "rhone-builder"
		type: "tar"
		mount: "/task/rhone"
		filters:
			- "uid keep"
			- "gid keep"
		silo: "file+ca://./wares/"
