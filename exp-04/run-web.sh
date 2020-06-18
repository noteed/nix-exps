#! /usr/bin/env bash

set -e

docker run -d --rm --name web -p 9000:80 web:latest
