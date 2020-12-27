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


## Notes

In the `build.sh` script, a `closure.tar.gz` file is created: it contains both
a cache directory and a result symlink into the Nix store. The cache directory
is used as a binary cache when calling `nix-restore` on the symlink.

Instead of using that directory and `file:///cache`, it is possible to push the
directory to S3 and use `https://some-bucket`.

The priority in the `nix-cache-info` file should be lower than the one from
`cache.nixos.org`.


## Exp-03

This experiment shows:

- How to create a qcow2 image of NixOS suitable for both qemu-kvm and
  DigitalOcean.

Note: See also [Nix notes](https://github.com/noteed/nix-notes).


### Description

The standard `nixpkgs` offers a few functions to build virtual machine images,
in particular with `nixos/maintainers/scripts/openstack/nova-image.nix` and the
function it uses, `make-disk-image.nix`.

Just like what is done in the nova-image file, we have a main file called
`qcow2.nix` that calls `make-disk-image.nix`. We provide twice our
configuration: once as an imported module to actually affect how the resulting
image is constructed, and once as string to define the content of
`/etc/nixos/configuration.nix` within the image.

A public SSH key of mine is hard-coded in the `config.nix`.

Some other ways to build images are described at
https://nixos.mayflower.consulting/blog/2018/09/11/custom-images/.


### Building

To build the `qcow2` file:

```
$ nix-build '<nixpkgs/nixos>' \
    -A config.system.build.qcow2 \
    --arg configuration "{ imports = [ ./qcow2.nix ]; }"
```


### Running with qemu-kvm

We create a configuration disk for cloud-init (hopefully mimicking what
DigitalOcean does; some documetation says they use a particular IP address,
some documetation says they use a disk...).

The disk is created by the helper script `make-cidata.sh`.

To run the result locally with qemu-kvm:

```
$ qemu-kvm -hda result/nixos.qcow2 \
    -m 4096 \
    -drive file=cidata.img,if=virtio \
    -nic user,hostfwd=tcp:127.0.0.1:2222-:22 \
    -no-reboot -snapshot -nographic
```

Once running, it should be possible to SSH into the VM with:

```
$ ssh -p 2222 nixos@127.0.0.1
```

Stopping the VM can be done with C-a x in the original shell.


### DigitalOcean

The image weights about 2.2GB, which is the size of its `/nix` store. Applying
gzip reduces it to 600MB.

After upload to DigitalOcean Spaces then import it in their custom images
section, it is possible to spin a new droplet. After a while, it is possible to
SSH into it.

Note that you have to configure a SSH key in their web interface even though
there is already one in the image.

The second time a droplet is created, the time to create it is more reasonable.


### Further configuration


In the `qcow2.nix` file, the main work is done by
`nixos/lib/make-disk-image.nix`. It uses a variable called `closureInfo`,
which, in that file, is derived from `toplevel channelSource`. In other places,
it is derived from `storeContents`. I think this is where to look to customize
the `/nix/store` within the created image (e.g. to reduce the 2.2GB size).


## Exp-04

This experiment shows:

- How to use `dockerTools`, an awesome nixpkgs utility to build Docker images
  from Nix expressions.
- How to do it from within a `nixos/nix` image: no need to have Nix on the host
  to use `dockerTools` !
- How to use the above with `skopeo` and `umoci` to create a single multi-step
  Dockerfile to build the final image in one command.

The final Docker image can be built directly with Nix with:

```
$ nix-build images.nix -A web
```

The `result` symlink can be loaded with `docker load -i`.

Alternatively, the image can be built by using the Nix Docker image, in two
steps:

```
$ ./build-cache.sh
$ ./build-web.sh
```

The first command is supposed be run rarely (e.g. once a week) to provide some
caching. The second step is the important one: it builds the final Docker image
within another image, then extracting it, and loading it.

As a convenience, a `run-web.sh` script is also provided:

```
$ ./run-web.sh
$ curl http://127.0.0.1:9000
```

Instead of using `build-web.sh` and the corresponding `images/web.Dockerfile`,
we can shift the work to a single Dockerfile, as shown in
`images/web-complete.Dockerfile`. Thus the final image can also be built with a
single `docker` command:

```
$ ./build-cache.sh
$ docker build -f images/web-complete.Dockerfile -t web .
```


## TODO

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

TODO See the cloud-init logs when spinnig an image at DigitalOcean, to see if
they provide a disk or if we should call their meta-data server.
