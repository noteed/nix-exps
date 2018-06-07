#! /usr/bin/env sh

cd /

echo Extracting closure tarball...
tar xf /closure.tar
rm -rf /nix/var/nix/binary-cache*
mkdir -p /etc/nix
echo "Priority: 10" >> /cache/nix-cache-info
echo "binary-caches = file:///cache/" > /etc/nix/nix.conf

echo Copying closure to Nix store...
nix-store -r /result > /dev/null 2>&1

echo Ok.
exec /result/bin/run
