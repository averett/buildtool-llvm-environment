#
# ubuntu base
#
FROM fedora AS build-base
RUN dnf -y update
RUN mkdir /install

#
# cmake install
#
FROM build-base AS build-cmake
ARG CMAKE_VERSION=3.22.1
RUN curl -sSL https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz | tar xz --strip-components=1 -C /install

#
# configured llvm source
#
FROM build-base AS build-llvm
COPY --from=build-cmake /install/ /usr/local
RUN dnf -y install xz ninja-build git && dnf -y group install "C Development Tools and Libraries" && dnf clean all
ARG LLVM_VERSION=13.0.0
RUN curl -sSL "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/llvm-project-${LLVM_VERSION}.src.tar.xz" | tar xJ
WORKDIR /llvm-project-${LLVM_VERSION}.src
ARG LLVM_PROJECTS="clang;clang-tools-extra;libcxx;libcxxabi;libunwind;lldb;compiler-rt;lld;polly;cross-project-tests"
RUN cmake -S llvm -B build -G "Ninja" -DLLVM_ENABLE_PROJECTS="$LLVM_PROJECTS" -DCMAKE_BUILD_TYPE="Release" -DCMAKE_INSTALL_PREFIX="/install"

FROM build-llvm


# vim: set ft=dockerfile:
