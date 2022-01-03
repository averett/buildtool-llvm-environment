FROM amazonlinux AS build-cmake
RUN yum -y install gzip tar

RUN mkdir /install && \
	curl -sSL https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-linux-x86_64.tar.gz | tar xz --strip-components=1 -C /install

FROM amazonlinux AS build-llvm
RUN yum -y groupinstall "Development Tools" && yum -y install \
	ninja-build python3
COPY --from=build-cmake /install/ /usr/local

RUN mkdir /install && \
	curl -sSL https://github.com/llvm/llvm-project/releases/download/llvmorg-13.0.0/llvm-project-13.0.0.src.tar.xz | tar xJ && \
	cd llvm-project-13.0.0.src && \
	cmake -S llvm -B build -G "Ninja" -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;libcxx;libcxxabi;libunwind;lldb;compiler-rt;lld;polly;cross-project-tests" -DCMAKE_BUILD_TYPE="Release" -DCMAKE_INSTALL_PREFIX="/install" && \
	cmake --build build --target install




