#!/bin/bash
set -e

base="$(dirname "$(readlink -f "$BASH_SOURCE")")"
dest="${base}/dockerfiles"

bin="${base}/bin"
include="inetutils-ping,iproute,lsb-release"

# Versions
declare -A build
build=(
    ['precise']='ubuntu'
    ['trusty']='ubuntu'
    ['vivid']='ubuntu'
    ['wily']='ubuntu'
    ['wheezy']='debian'
    ['jessie']='debian'
    ['stretch']='debian'
)

# Variant types
variant=(
    'minbase'
)

declare -A urls
urls=(
    ['ubuntu']='http://de.archive.ubuntu.com/ubuntu'
    ['debian']='http://ftp.nl.debian.org/debian'
)


function build()
{
    distro="${1}"
    version="${2}"
    type="${3}"

    if [[ "${type}" == "buildd" ]]; then
        curdest="${dest}/${type}/${distro}/${version}"
    else
        curdest="${dest}/${distro}/${version}"
    fi

    build_log="${curdest}/build.log"

    include="inetutils-ping,iproute,lsb-release"
    if [[ "${distro}" == "ubuntu" ]]; then
        components="main,beta,universe,backports"
    elif [[ "${version}" == "stretch" ]]; then
        components="main,beta"
	include="${include},python3"
    else
        components="main,beta"
    fi

    echo
    mkdir -p "${curdest}"
    sudo ${bin}/mkimage.sh -d "${curdest}" debootstrap \
        --components="${components}" \
        --variant="${type}" \
        --include="${include}" \
        --force-check-gpg \
        "${version}" \
        "${urls[${distro}]}" 2>&1 | tee ${build_log}
    echo

    return 0
}

if [ -z "${@}" ]; then
    for version in ${!build[@]}; do
        # Set variables
        distro="${build[${version}]}"

        # Execute processes
        for type in ${variant[@]}; do
            build "${distro}" "${version}" "${type}"
        done
    done
else
    for version in ${@}; do
        # Set variables
        distro="${build[${version}]}"

        # Execute processes
        for type in ${variant[@]}; do
            build "${distro}" "${version}" "${type}"
        done
    done
fi

sudo chown -R "$(id -n -u ${USER}):$(id -n -g ${USER})" "${dest}"
git add "${dest}"/

echo

echo "Done"
