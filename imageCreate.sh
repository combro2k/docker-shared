#!/bin/bash
set -e

# Base settings
variant="minbase"
base="$(dirname "$(readlink -f "$BASH_SOURCE")")"
dest="${base}/dockerfiles"

bin="${base}/bin"
include="inetutils-ping,iproute,vim-nox,less"

# Versions
declare -A build
build=(
    ['trusty']='ubuntu'
    ['vivid']='ubuntu'
    ['wily']='ubuntu'
    ['wheezy']='debian'
    ['jessie']='debian'
    ['stretch']='debian'
)

declare -A urls
urls=(
    ['ubuntu']='http://archive.ubuntu.com/ubuntu'
    ['debian']='http://httpredir.debian.org/debian'
)


function build()
{
    curdest="${dest}/${1}/${2}"
    build_log="${curdest}/build.log"

    components="main"
    [[ "${1}" == "ubuntu" ]] && components+=",universe"

    echo
    mkdir -p "${curdest}"
    sudo ${bin}/mkimage.sh -d "${curdest}" debootstrap \
        --components="${components}" \
        --variant="${variant}" \
        --include="${include}" \
        --force-check-gpg \
        "${2}" \
        "${urls[${1}]}" 2>&1 | tee ${build_log}
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
