# Nix Experiments (and actually working Nix expressions)

This is an assorted list of Nix experiments. They should be useful by
themselves to learn a few tricks, but hopefully put together, they will result
in something interesting.


## Exp-01

This experiment shows:

- How to run a Nixified `nginx -c nginx.conf`, i.e. how to craft the
  configuration file and pass its path to Nginx.
- How to package the resulting script (together with all its dependencies, i.e.
  its closure) into a Docker image.


## Building (without installing)

(Assuming exp-01 is the current directory.)

```
$ ./build.sh
```

The result of the Nix build is visible as a symlink "result" in the current
directory. It contains a "run" script that can be executed as-is. To "install"
it, see below.

In addition to the Nix build itself, this also creates a hypered/nix Docker
image that is able to extract the tarball into its Nix store, then run its
"run" script.

(The script is called "run" so that the hypered/nix Docker image doesn't have
to guess its name. In practice this should be made more flexible.)


## Installing

```
$ nix-env --install -A exp-01-nginx -f default.nix
```

In practice, this means building the Nix expression just as above, but also
putting the "run" script in the PATH.


## Uninstalling

In practice, this means removing the "run" script from the PATH.

```
$ nix-env --uninstall exp-01-nginx
```


## Docker image

It is possible to package a Nix program to create a Docker image, see
http://mstone.info/posts/nix-20151018/#deploying-nix-closures-to-docker

The technique is used in the above "build.sh" script (although the resulting
image "awaits" the closure to run, which is given by using a volume).

The result can be run as follow:

```
$ docker run -d -p 8080:8080 -v $(pwd)/closure.tar:/closure.tar hypered/nix
```

TODO Another image with the tarball exctraction/restore already made (i.e. no
volume required), maybe using build-trigger.
