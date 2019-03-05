#! /usr/bin/env bash

truncate --size 2M cidata.img
mkfs.vfat -n cidata cidata.img > /dev/null 2>&1
mcopy -oi cidata.img user-data meta-data ::
