#!/bin/bash
set -xeo pipefail

# A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

while getopts "d:" opt; do
    case "$opt" in
        d)  DOCKER_REPO=$OPTARG
        ;;
    esac
done

if [ "${DOCKER_REPO}" = "" ]; then
    echo "DOCKER_REPO is required." 1>&2
    exit 1
fi

# Test cases

# It should register binfmt_misc entry with 'flags: F'
# by given "-p yes" option.
sudo docker run --rm --privileged ${DOCKER_REPO} --reset -p yes
cat /proc/sys/fs/binfmt_misc/qemu-aarch64
grep -q 'flags: F' /proc/sys/fs/binfmt_misc/qemu-aarch64

# It should register binfmt_misc entry with 'flags: '
# by given no "-p yes" option.
sudo docker run --rm --privileged ${DOCKER_REPO}:register --reset
cat /proc/sys/fs/binfmt_misc/qemu-aarch64
grep -q 'flags: ' /proc/sys/fs/binfmt_misc/qemu-aarch64

# /usr/bin/qemu-aarch64-stati should be included.
docker run --rm -t ${DOCKER_REPO}:aarch64 /usr/bin/qemu-aarch64-static --version
docker run --rm -t ${DOCKER_REPO}:x86_64-aarch64 /usr/bin/qemu-aarch64-static --version
