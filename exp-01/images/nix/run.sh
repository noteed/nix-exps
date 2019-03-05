#! /usr/bin/env sh

cd /

echo Extracting closure tarball...
tar xf /closure.tar
rm -rf /nix/var/nix/binary-cache*
mkdir -p /etc/nix
echo "binary-caches = file:///cache/" > /etc/nix/nix.conf

echo Copying closure to Nix store...
nix-store -r /result

echo Ok.
exec /result/bin/run
