
misc scratch notes
------------------

This is not a set of formulas that produces reasonable results.  It works, roughly, but it's not the minimal we're looking for.

### other stuff to look at

- this says "minimal" and means it: https://hub.docker.com/r/blitznote/debootstrap-amd64/
  - unfortunately the image rebuild process is described in a *comment* rather than say being in a container: https://github.com/Blitznote/docker-ubuntu-debootstrap/issues/2#issuecomment-256456602

- 'multistrap' looks like it might have a much more reasonable interface than debootstrap for what we're trying to do
  - but also more deps on the enclosing apt toolchain, which is a little suboptimal, but probably not worth caring.
