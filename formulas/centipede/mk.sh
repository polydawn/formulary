#!/bin/sh
set -x
sudo debootstrap --include build-essential,gawk stable centipede_zero
(
	cd centipede_zero
	sudo tar czf ../centipede_zero.tar.gz .
)
sudo chown $USER centipede_zero.tar.gz
