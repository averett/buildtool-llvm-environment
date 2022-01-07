#
# base image
#
FROM fedora AS base
RUN dnf -yq update

#
# build tools
#
FROM base as build-tools
RUN dnf -yq group install "C Development Tools and Libraries"
RUN dnf -yq install clang clang-tools-extra
RUN dnf -yq install cmake

FROM build-tools
