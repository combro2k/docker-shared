#!/bin/bash
set -e

# Base settings
variant="minbase"
base="$(dirname "$(readlink -f "$BASH_SOURCE")")"
dest="${base}/dockerfiles"

bin="${base}/bin"
include="inetutils-ping,iproute2,net-tools,vim-nox,less"

# Versions
declare -A build
build=(
    ['trusty']='ubuntu'
    ['vivid']='ubuntu'
    ['willy']='ubuntu'
    ['wheezy']='debian'
    ['jessie']='debian'
    ['stretch']='debian'
)

declare -A urls
urls=(
    ['ubuntu']='http://archive.ubuntu.com/ubuntu'
    ['debian']='http://http.debian.net/debian/'
)


function build()
{
    curdest="${dest}/${1}/${2}"
    build_log="${curdest}/build.log"

    echo
    mkdir -p "${curdest}"
    sudo ${bin}/mkimage.sh -d "${curdest}" debootstrap \
        --components="main,universe" \
        --variant="${variant}" \
        --include="${include}" \
        --force-check-gpg \
        "${2}" \
        "${urls[${1}]}" > ${build_log} 2>&1
    echo

    return 0
}


for version in ${!build[@]}
do
    # Set variables
    distro="${build[${version}]}"


    # Execute processes
    build "${distro}" "${version}"
done

sudo chown -R "$(id -n -u ${USER}):$(id -n -g ${USER})" "${dest}"
git add "${dest}"/

echo

echo "Done"
