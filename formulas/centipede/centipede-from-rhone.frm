inputs:
	"/":
		type: "tar"
		hash: "-IP_ZOz30QZTXCL70RnykcNhgN1nRyI3zyBUkaSBUR0xVqn3O0-2x_ZwWR_Btjg5"
		silo: "file+ca://./wares"
	"/bootstrap/glibc":
		type: "tar"
		hash: "N-tnJ5vuP7cLHvkVV2wdCOpE2P6njprCFw8gThV86T_-5vuUBOZClILXhh5DIc52"
		silo: "https://ftp.gnu.org/gnu/glibc/glibc-2.21.tar.bz2"
	"/bootstrap/bash":
		type: "tar"
		hash: "eMC6k6LJMGNctTlqwUdg5TQYjpMAypSdkoABbGLUqeqnbJZBhbuNcTWOlJEXC3GE"
		silo: "https://ftp.gnu.org/gnu/bash/bash-4.3.30.tar.gz"
	"/bootstrap/gcc":
		type: "tar"
		hash: "r3BCHaK3I4JUQcOttPvV6MjuKleytKuuOwWcOp3f-xj2exkRvJu_p3WdjuuY9Wyo"
		silo: "https://ftp.gnu.org/gnu/gcc/gcc-4.9.3/gcc-4.9.3.tar.bz2"
	"/bootstrap/binutils":
		type: "tar"
		hash: "vOywUIRbfEWRfcJ1nLm7Mm7ND1ZnadPsqg-AnmJGqxLh0G916VuLLzBThfXZ-bWA"
		silo: "https://ftp.gnu.org/gnu/binutils/binutils-2.25.1.tar.bz2"

action:
	command:
		- "/bin/bash"
		- "-c"
		- |
			set +h
			umask 022
			ROOT=/target
			LC_ALL=POSIX
			ROOT_TGT=$(uname -m)-looinx
			PATH=/tools/bin:/bin:/usr/bin
			export ROOT LC_ALL ROOT_TGT PATH
			mkdir -vp $ROOT/tools
			ln -sv $ROOT/tools /

			cd /bootstrap/glibc/
			mkdir build && cd build
			../glibc-2.21/configure        \
				--prefix=/tools            \
				--with-sysroot=$ROOT       \
				--with-lib-path=/tools/lib \
				--target=$ROOT_TGT         \
				--disable-nls              \
				--disable-werror

outputs:
	"/target":
		type: "tar"
		mount: "/target"
		silo: "file+ca://./wares"
