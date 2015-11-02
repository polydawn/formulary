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


