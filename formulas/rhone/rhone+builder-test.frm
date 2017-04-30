### Sanity tester that the 'rhone-builder' image works
### and the gcc embedded can compile basic C code.
inputs:
	"/":  {tag: "rhone-builder"}
action:
	command:
		- "/bin/bash"
		- "-c"
		- |
			#!/bin/bash
			set -euo pipefail
			set -x

			cat > hello.c <<EOF
				int main(void) {
					puts("Hello World\n");
					return 0;
				}
			EOF

			find / -name crti.o || true

			gcc hello.c || true
			ls -lah

			./a.out
