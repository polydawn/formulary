### Sanity tester that the 'rhone' image supports a regular rust compiler.
inputs:
	"/":  {tag: "rhone"}
	"/app/rust":
		type: "tar"
		hash: "0-v-l3Fb7eH56YfXVVwdGur3WhY0IUlZZyrjF9Jvcfat3o2v65GcyrHTLOK4J29U"
		silo: "https://static.rust-lang.org/dist/rust-1.17.0-x86_64-unknown-linux-gnu.tar.gz"
action:
	env:
		"PATH": "/bin/:/usr/bin/:/app/rust/rust-1.17.0-x86_64-unknown-linux-gnu/rustc/bin/"
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x

			ldd `which rustc`
			rustc
