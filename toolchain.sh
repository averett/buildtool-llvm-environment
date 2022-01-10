#!/bin/bash

show_help() {
	echo "toolchain <target triple> <rootfs path>"
}
show_error() {
	1>&2 echo $@
}

toolchain() {
	if [[ -z "$1" ]]; then
		show_help
		exit 1
	fi

	# split tuple
	local tuple=(${1//-/ })
	if (( ${#tuple[@]} != 4 )); then
		show_help
		show_error 'invalid target triple'
		exit 2
	fi

	if [[ -z "$2" ]]; then
		show_help
		show_error 'must pass rootfs directory'
		exit 1
	fi

	local sysroot=''
	for i in "$2" "${2}/${1}"; do
		if [[ -d $i ]]; then
			sysroot=$(cd $i && pwd)
		fi
	done
	
	if [[ -z "$sysroot" ]]; then
		show_help
		show_error 'sysroot could not be found'
		exit 1
	fi

	local arch=${tuple[0]}
	local vendor=${tuple[1]}
	local sys=${tuple[2]}
	local abi=${tuple[3]}

	local system=''
	if [[ "$sys" == 'linux' ]]; then
		system='Linux'
	elif [[ "$sys" == 'windows' ]]; then
		system='Windows'
	fi

	sed -r \
		-e "s/(CMAKE_SYSTEM_PROCESSOR )[^\)]*/\1${arch}/" \
		-e "s/(CMAKE_SYSTEM_NAME )[^\)]*/\1${system}/" \
		-e "s/(CMAKE_C(XX)?_COMPILER_TARGET )[^\)]*/\1${1}/" \
		< /tuple.cmake

	printf 'set(CMAKE_SYSROOT "%s")\n' "${sysroot}"
}
toolchain $@

