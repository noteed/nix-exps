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


### Building (without installing)

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


### Installing

```
$ nix-env --install -A exp-01-nginx -f default.nix
```

In practice, this means building the Nix expression just as above, but also
putting the "run" script in the PATH.


### Uninstalling

In practice, this means removing the "run" script from the PATH.

```
$ nix-env --uninstall exp-01-nginx
```


### Docker image

It is possible to package a Nix program to create a Docker image, see
http://mstone.info/posts/nix-20151018/#deploying-nix-closures-to-docker

The technique is used in the above "build.sh" script (although the resulting
image "awaits" the closure to run, which is given by using a volume).

The result can be run as follow:

```
$ docker run -d -p 8080:8080 -v $(pwd)/closure.tar:/closure.tar hypered/nix
```


## Exp-02

This experiment shows:

- How to create files and directories respecting some structure; here we want
  to respect what s6-svscan requires.
- How to use a Nix shell instead of installing or building an expression.


### Description

The second experiment creates a few directories and scripts suitable for
s6-svscan. Just like the exp-01 creates a script to launch Nginx with the
crafted configuration file, here we have a run script to launch s6-svscan.

The default.nix file defines a services-shell environment that contains
run.


### Using nix-shell

(Assuming exp-02 is the current directory.)

You can enter the environment with:

```
$ nix-shell --pure -A services-shell
```

There, the script run in is the PATH (i.e. without installing it).

Alternatively, it can be run directly:

```
$ nix-shell --pure -A services-shell --run run
```

Note: We can write the services-shell derivation within a shell.nix file so
that nix-shell with any argument works.


### Docker image

See the same section from the previous experiment about creating a Docker
image.

The result can be run as follow:

```
$ docker run -d -v $(pwd)/closure.tar:/closure.tar hypered/nix
```


### TODO

TODO Use busybox and execlineb for the above, not coreutils or bash.

TODO Use versions of busybox and execlineb linked against musl.

TODO Another image with the tarball exctraction/restore already made (i.e. no
volume required), maybe using build-trigger, built on the existing image.

TODO Document how to run the above on Debian (usefull for e.g. Digital Ocean),
and Alpine Linux (usefull for e.g. Scaleway).

TODO The next experiment should create a kvm image similar to the above.

TODO The next experiment should combine the Nginx and S6 examples together.

TODO Use the same "interface" to run Nginx than S6 (i.e. reuse `$ nix-shell
--pure -A services-shell --run run` from the "Using nix-shell"
section). Or maybe it should be something like `$(nix-build
...)/bin/run` in both cases ?
