##
## The following script is a contained environment with deterministic inputs (checked by a strong hash)
## which uses the go1.5 release for linux to *build* the go1.5 binaries for linux.
##
## It then hashes the results so you can easily check that they are self-consistent when you run this process
## repeatedly on your own computer.  (The use of sandboxes means we're confident there's no leakage
## of state across repetitions.)
##
## Note that this does *not* check that the results are identical to the `bin` folder in the upstream
## release we started with as the bootstrap compiler.
## We would certainly *like* those results to be the same!  That would *make sense*, and help us
## verify that the upstream builds from source have not been tampered with (or simply fallen
## prey to miscelanous bugs which make them host-dependent, etc).
## However, they are in fact, not.
##
inputs:
	"/":
		type: "tar"
		hash: "aLMH4qK1EdlPDavdhErOs0BPxqO0i6lUaeRE4DuUmnNMxhHtF56gkoeSulvwWNqT"
		silo:
			- "file+ca://./wares/"
			- "http+ca://repeatr.s3.amazonaws.com/assets/"
	"/app/go/":
		type: "tar"
		hash: "vbl0TwPjBrjoph65IaWxOy-Yl0MZXtXEDKcxodzY0_-inUDq7rPVTEDvqugYpJAH"
		silo: "https://storage.googleapis.com/golang/go1.5.linux-amd64.tar.gz"
	"/task/go-src/":
		type: "tar"
		hash: "vbl0TwPjBrjoph65IaWxOy-Yl0MZXtXEDKcxodzY0_-inUDq7rPVTEDvqugYpJAH"
		silo: "https://storage.googleapis.com/golang/go1.5.linux-amd64.tar.gz"
action:
	env:
		"GOROOT_BOOTSTRAP": "/app/go/go/"     # essential
		"CGO_ENABLED": "0"                    # essential (otherwise a C compiler is required)
		"GOROOT_FINAL": "/usr/local/go"      # pleasantry -- act like upstream.  (note that the build won't put new files here, it just goes into the symbols)
		#"GOBIN": "/task/output"
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x

			## Compiling go with `make.bash` will use the source relative to the CWD.
			##  The CWD is required to be the same location as `make.bash`.
			## The GOROOT_BOOTSTRAP *also* needs to point at a source directory,
			##  and not merely a copy of the binary tools necessary for bootstrapping,
			##  because `make.bash` will set GOROOT to GOROOT_BOOTSTRAP.
			## The binaries produced with `make.bash` will be placed in the neighboring
			##  `bin` directory.
			## Note that this means if you want unambiguous outputs,
			##  (e.g. $CWD/bin/ should be empty before compile and full after)
			##  GOROOT_BOOTSTRAP and CWD *cannot* be set to the same dir!
			##  If they were, you'd need to remove your own bootstrap binaries
			##  before starting work, which obviously doesn't fly :)
			## As a result of all this, I can't find a way to avoid having
			##  two entire copies of the go source, despite them being -- your
			##  eyes do not deceive you -- literally and entirely the same content.
			## TODO: test if setting GOBIN can do it?
			
			# Switch to the destination tree
			cd /task/go-src/go/

			# Remove existing binaries so we have an unfettered result area.
			# n.b. we could also start from a git clone, but it certainly seems
			#  reasonable to try to rebuild the binaries from the packaged
			#  sources, don't you agree?
			rm -v ./bin/*

			# Switch to the src tree.  `make.bash` explicitly requires it.
			cd ./src/
			
			# Quick sanity check printout of what files we have before we rock.
			echo "PRE-BUILD BIN DIRS ====>"
			ls -lah /app/go/go/bin/
			sha384sum /app/go/go/bin/* || true 
			ls -lah /task/go-src/go/bin/
			sha384sum /task/go-src/go/bin/* || true # errors because empty
			echo "<======="

			./make.bash --no-clean

			# Quick list of files we got after finishing
			#  (and per-file hashes -- turns out not all the same binaries are produced at all).
			echo "POST-BUILD BIN DIRS ====>"
			ls -lah /app/go/go/bin/
			sha384sum /app/go/go/bin/* || true 
			ls -lah /task/go-src/go/bin/
			sha384sum /task/go-src/go/bin/* || true 
			ls -lah /task/output/
			sha384sum /task/output/* || true 
			echo "<======="
outputs:
	"/task/output/":
		type: "dir"
		silo: "file+ca://./wares/"
	"/task/go-src/go/bin/":
		## These are our actual results.
		type: "dir"
		silo: "file+ca://./wares/"
	"/app/go/go/bin":
		## This is just asking for a hash of the bootstrap compiler binaries.
		## We don't actually need to save the files -- this is just to help
		##  immediately constrast with the hash to our own build results.
		type: "dir"
