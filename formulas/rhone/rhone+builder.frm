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
			### The following is the total set you get for resolving "build-base".
			###  We've cherry-picked the minimal things we can get away with; the rest are commented out.
			#packages+=("musl") ## implied by 'gcc'
			#packages+=("zlib") ## implied by 'gcc'
			#packages+=("binutils-libs") ## implied by 'gcc'
			#packages+=("binutils") ## implied by 'gcc'
			#packages+=("gmp") ## implied by 'gcc'
			#packages+=("isl") ## implied by 'gcc'
			#packages+=("libgomp") ## implied by 'gcc'
			#packages+=("libatomic") ## implied by 'gcc'
			#packages+=("pkgconf") ## implied by 'gcc' (yes, really)
			#packages+=("libgcc") ## implied by 'gcc'
			#packages+=("mpfr3") ## implied by 'gcc'
			#packages+=("mpc1") ## implied by 'gcc'
			#packages+=("libstdc++") ## implied by 'gcc'
			packages+=("gcc")
			#packages+=("musl-dev") ## implied by 'libc-dev'
			packages+=("libc-dev")
			#packages+=("g++")
			packages+=("make")
			#packages+=("fortify-headers")

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
