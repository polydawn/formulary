##
## Build git.
##
## WIP.  Not all features of git work satisfactorily.
##
## We're interested in this in general (auditable formula for transmat plugins is a
## a first class goal -- the transparency benefits should be self-explanitory),
## and in particular to ensure we have a version of get with a variety of recent features:
##  - https://www.mail-archive.com/git@vger.kernel.org/msg82063.html -- critical to working on a host with unknown uid/name configs.
##  - some serious issues around `git ls-remote` behaviors with relative paths I don't have issue numbers for (although, no, actually, those still exist on tip evidentally).
##  - generally having something statically linked for sanity and ease of distribution.
##
##
inputs:
	"/":
		## Adviso: contains many build deps which are somewhat arbitrary.  would prefer to replace with properly piecewise and well-pinned deps in the future.
		type: "tar"
		hash: "xK30HS-fszVKemoy2G66_1y5-ppBuuL5_T4CexlIETQojPONkleMi-j2YhvmeYF5" ## staid-ubuntu/ubuntu-14.04.04+builder.frm
		silo:
			- "file+ca://./wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
	"/task/src/":
		type: "tar"
		hash: "Ovzbw0YMzjw2TW7tuEfMxm7UWwPJSoPiiYSXRy9PBMEK7NIbpqlMcerfKEMLNzKX"
		silo: "https://www.kernel.org/pub/software/scm/git/git-2.7.2.tar.xz"
action:
	policy: governor ## git tarball contains rude uids.  need will be removed when input filters are implemented.
	env:
		"NO_PERL": "true"
		"NO_PYTHON": "true"
		"NO_TCLTK": "true"
		#"NO_CROSS_DIRECTORY_HARDLINKS": "true"
		#"NO_INSTALL_HARDLINKS": "true"
		"NO_GETTEXT": "true"
		"NO_MSGFMT": "true" ## you wish
	command:
		- bash
		- -c
		- |
			set -euo pipefail
			set -x

			## Elide need for more translations.
			##  ("NO_GETTEXT" and "NO_MSGFMT" appear not to be respected,
			##   despite a variety of stackoverflow, etc docs to the subject.)
			echo "" > /usr/bin/msgfmt
			chmod +x  /usr/bin/msgfmt

			cd src/*

			## I'd love to go full static, but currently haven't yet worked
			##  around some substantial errors in libcrypto.
			#CFLAGS='-static' \
			./configure || cat config.log
			make install prefix=/task/bin/
			ls -lah --color
			ldd ./git || true
outputs:
	"/task/src/":
		type: "dir"
		silo: "file+ca://./wares/"
	"/task/bin/":
		## Notes:
		##   - quite big compared to what I see on my host distro;
		##   - the install instructions refer to use of GIT_EXEC_PATH to make the
		##      path portable, but I haven't observed this to work yet.
		type: "dir"
		silo: "file+ca://./wares/"
