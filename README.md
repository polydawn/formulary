formulary
=========

Formulary is a collection of formulas for use with the [repeatr](https://github.com/polydawn/repeatr) project!

Formulas list a collection of inputs, some computation to run, and optionally, some outputs to collect.  Like this:

```yaml
inputs:
	"/":
		type: "tar"
		hash: "uJRF46th6rYHt0zt_n3fcDuBfGFVPS6lzRZla5hv6iDoh5DVVzxUTMMzENfPoboL"
		silo: "http+ca://repeatr.s3.amazonaws.com/assets/"
	"/app/go/":
		type: "tar"
		hash: "vbl0TwPjBrjoph65IaWxOy-Yl0MZXtXEDKcxodzY0_-inUDq7rPVTEDvqugYpJAH"
		silo: "https://storage.googleapis.com/golang/go1.5.linux-amd64.tar.gz"
	"/some-project:
		type: "git"
		hash: "13362100c5ebd4c36b1e6780c191ef7abee32f7f"
		silo: "https://github.com/polydawn/repeatr.git"
action:
	command:
		- "/some-project/your_command"
		- "--with"
		- "arguments"
	cwd: "/tmp"
outputs:
	"product":
		type: "tar"
		mount: "/tmp/output"
		filters:
			- uid 10100
			- gid 10100
		silo: "s3+ca://yourbucket.aws.amazon.com/storage-pool/"
```

You can run formulas like that one by saving them to a file, and then running them with repeatr like this:

```bash
	repeatr run -i your-formula.yaml
```

Happy (repeatable) hacking!


### Note on paths

Prepackaged formulas in this repo mostly refer to "file+ca://./wares/" as their output locations,
which means (as you'd expect):

- Use a local filesystem for storage
- Act like it's content-addressable (so you can store as many things as you want there without bothering to name them individually)
- Use a dir relative to where the process was launched.

So, if your current directory is the repo root dir when you ask repeatr to run the formulas,
the `./wares` dir will be used -- this dir should already exist when you clone this repo (it contains a gitignore).
On the other hand, if you `cd` down into the formula dirs and then run things, you'll be informed that there's no wares dir there.
Of course, you're free to reconfigure this however you want, or create other directories and run repeatr starting from there
on purpose to keep separate stockpiles of results.
