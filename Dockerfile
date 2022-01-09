#
# base image
#
FROM fedora AS base
RUN dnf -yq update

#
# clang and cmake
#
FROM base as build-tools
RUN dnf -yq group install "C Development Tools and Libraries"
RUN dnf -yq install clang clang-tools-extra
RUN dnf -yq install cmake
RUN dnf -yq install lld

COPY toolchain.sh /usr/local/bin/toolchain
COPY tuple.cmake /

