
#
# updated base image
#
FROM fedora AS fedora-base
RUN dnf -yq update

#
# llvm source
#
FROM fedora-base AS llvm-src
RUN dnf -yq install xz
# download the source and switch to source directory
ARG LLVM_VERSION=13.0.0
RUN curl -sSL "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/llvm-project-${LLVM_VERSION}.src.tar.xz" | tar xJ
RUN mv llvm-project-${LLVM_VERSION}.src llvm-project.src

#
# base build image
#
FROM fedora-base AS build-base
RUN dnf -yq group install "C Development Tools and Libraries" && mkdir /install
RUN dnf -yq install ninja-build cmake git glibc-devel.i686 perl

#
# phase 1 build
#
FROM build-base AS build-llvm-1
COPY --from=llvm-src /llvm-project.src /llvm-project.src
WORKDIR /llvm-project.src
RUN cmake -S llvm -B build -G "Ninja" -DCMAKE_BUILD_TYPE="Release" -DCMAKE_INSTALL_PREFIX="/install" \
	-DLLVM_ENABLE_RUNTIMES="all" -DLLVM_INSTALL_UTILS=On -DLLVM_TARGETS_TO_BUILD=Native \
	-DLLVM_INSTALL_BINUTILS_SYMLINKS=On -DLLVM_INSTALL_CCTOOLS_SYMLINKS=On \
	-DLLVM_INCLUDE_BENCHMARKS=Off -DLLVM_INCLUDE_EXAMPLES=Off -DLLVM_INCLUDE_TESTS=Off \
	-DLLVM_ENABLE_PROJECTS="clang;lld"
	
RUN cmake --build build
RUN cmake --build build --target install

FROM fedora-base AS build-cmake
RUN mkdir /install && \
	curl -sSL https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-linux-x86_64.tar.gz | tar xz --strip-components=1 -C /install

FROM build-base AS build-perl
RUN curl -sSL https://www.cpan.org/src/5.0/perl-5.34.0.tar.gz | tar xz
WORKDIR /perl-5.34.0
RUN ./Configure -des -Dprefix=/install
RUN make test && make install

#
# phase 2 build
#
FROM fedora-base AS build-llvm-2
RUN dnf -yq install ninja-build git
COPY --from=build-llvm-1 /install/ /usr/local
COPY --from=llvm-src /llvm-project.src /llvm-project.src
WORKDIR /llvm-project.src

COPY --from=build-cmake /install/ /usr/local
COPY --from=build-perl /install/ /usr/local

RUN dnf -yq install gcc-x86_64-linux-gnu
#RUN ln -s /usr/local/bin/ld.lld /usr/local/bin/ld
#RUN dnf -yq install glibc
# run cmake
#ARG LLVM_PROJECTS="clang;clang-tools-extra;cross-project-tests;libclc;lld;lldb;mlir;polly;pstl"
#RUN cmake -S llvm -B build -G "Ninja" -DCMAKE_BUILD_TYPE="Release" -DCMAKE_INSTALL_PREFIX="/install" \
#	-DLLVM_ENABLE_RUNTIMES="all" -DLLVM_ENABLE_PROJECTS="${LLVM_PROJECTS}" -DLLVM_USE_LINKER=lld \
#	-DLLVM_INSTALL_BINUTILS_SYMLINKS=On -DLLVM_INSTALL_CCTOOLS_SYMLINKS=On \
#	-DLLVM_INCLUDE_BENCHMARKS=Off -DLLVM_INCLUDE_EXAMPLES=Off -DLLVM_INCLUDE_TESTS=Off \
#	-DLLVM_INSTALL_UTILS=On
#RUN cmake --build build
#RUN mkdir /install && cmake --build build --target install

#
# final image
#
#FROM fedora-base
#RUN dnf -yq install ninja-build cmake git perl
#COPY --from=build-llvm-2 /install/ /usr/local

# vim: set ft=dockerfile:
