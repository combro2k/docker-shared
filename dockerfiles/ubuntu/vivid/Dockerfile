FROM scratch
ADD rootfs.tar.xz /
ONBUILD apt-get update && apt-get dist-upgrade -y && apt-get clean && rm -fr /var/lib/apt
CMD ["/bin/bash"]
