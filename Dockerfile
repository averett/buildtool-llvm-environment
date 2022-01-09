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

##
## ubuntu:lts toolchain
##
#FROM ubuntu:20.04 AS ubuntu-lts-toolchain
#RUN apt-get update
#RUN apt-get -yq install debootstrap
##RUN apt-get -yq install mmdebstrap
##RUN mkdir /install
#RUN debootstrap \
#	--arch=amd64 \
#	--variant=required \
#	focal /install http://us.archive.ubuntu.com/ubuntu/
##RUN mmdebstrap \
##	--architectures=amd64 \
##	--variant=required \
##	--mode=auto \
##	--include=build-essential \
##	focal /install http://us.archive.ubuntu.com/ubuntu/
#
#FROM build-tools
#COPY --from=ubuntu-lts-toolchain /install/ /toolchains/x86_64-ubuntu-linux-gnu/

