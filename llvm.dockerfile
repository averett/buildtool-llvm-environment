#
# ubuntu base
#
FROM fedora AS build-base
RUN dnf -yq update
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

# install the tools
COPY --from=build-cmake /install/ /usr/local
RUN dnf -yq install xz ninja-build git rsync && dnf -yq group install "C Development Tools and Libraries" && dnf -q clean all

# download the source and switch to source directory
ARG LLVM_VERSION=13.0.0
RUN curl -sSL "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/llvm-project-${LLVM_VERSION}.src.tar.xz" | tar xJ
WORKDIR /llvm-project-${LLVM_VERSION}.src

# run cmake
ARG LLVM_PROJECTS="clang;clang-tools-extra;libcxx;libcxxabi;libunwind;lldb;compiler-rt;lld;polly;cross-project-tests"
RUN cmake -S llvm -B build -G "Ninja" -DLLVM_ENABLE_PROJECTS="$LLVM_PROJECTS" -DCMAKE_BUILD_TYPE="Release" -DCMAKE_INSTALL_PREFIX="/install" \
	-DLLVM_INSTALL_BINUTILS_SYMLINKS=1 -DLLVM_INSTALL_CCTOOLS_SYMLINKS=1 \
	-DLLVM_INCLUDE_BENCHMARKS=0 -DLLVM_INCLUDE_EXAMPLES=0 -DLLVM_INCLUDE_TESTS=0 \
	-DLLVM_INSTALL_UTILS=1

# build, test and install the project
RUN cmake --build build
#RUN cmake --build build --target check
RUN cmake --build build --target install

FROM build-base
RUN dnf -yq install ninja-build && dnf -q clean all
COPY --from=build-cmake /install/ /usr/local
COPY --from=build-llvm /install/ /usr/local
RUN ln -s /usr/local/bin/ld.lld /usr/local/bin/ld


# vim: set ft=dockerfile:
