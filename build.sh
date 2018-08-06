#!/bin/bash

die()
{
	echo "Error: $@" >&2
	echo "Please fix the error and retry"
	exit 1
}

try_mkdir()
{
	[ -d "$1" ] || mkdir "$1"
}

do_build()
{
	local comp=$1
	local jobs=$2
	
	[[ "$comp" =~ ^gcc|clang$ ]] ||
		die "Compiler must be \"gcc\" or \"clang\""
	local compexe
	if [ $comp == "gcc" ]
	then
		cexe="gcc"
		cppexe="g++"
	else
		cexe="clang"
		cppexe="clang++"
	fi
    
	[[ $jobs =~ ^[0-9]+$ ]] || die "Number of jobs must be numeric"
	
	local lmmsrc="$HOME/.lmmsrc.xml"
	[ -f "$lmmsrc" ] || die "Could not find LMMS RC file \"$lmmsrc\""
	local lmms_workdir=$(sed -n 's/^.*workingdir=\"\([^"]\+\)\".*$/\1/p' "$lmmsrc")
	[ -d "$lmms_workdir" ] || die "Could not find LMMS working dir in $lmmsrc"

	local builddir="build-$comp"
	local installdir="install-$comp"

	pushd spa
	try_mkdir $builddir
	pushd $builddir
	cmake -DCOMPILER=$comp -DCMAKE_INSTALL_PREFIX="$PWD/../$installdir" -DCMAKE_BUILD_TYPE=Release ..
	make -j $jobs
	make install
	popd
	local spa_pkg_config_dir="$PWD"/$installdir/lib/pkgconfig/
	spa_pkg_config_dir="$PWD"/$installdir/lib64/pkgconfig/
	[ -d $spa_pkg_config_dir ] || die "Could not find pkg config file in spa installation"
	popd
	
	pushd mruby-zest-build
	CC=$cexe make setup
	CC=$cexe make builddep
	CC=$cexe make -j $jobs
	CC=$cexe make pack
	popd
	
	pushd zynaddsubfx
	try_mkdir $builddir
	pushd $builddir
	[ -r CMakeCache.txt ] ||
		PKG_CONFIG_PATH=$spa_pkg_config_dir:"$PKG_CONFIG_PATH" cmake \
		-DCMAKE_C_COMPILER=$cexe \
		-DCMAKE_CXX_COMPILER=$cppexe \
		-DCMAKE_BUILD_TYPE=Release \
		-DGuiModule=zest \
		-DZynFusionDir=../../mruby-zest-build/package \
		..
	make -j $jobs
	popd
	local zyn_plugin_dir="$PWD/$builddir/src/Output"
	[ -f "$zyn_plugin_dir"/libzynaddsubfx_spa.so ] ||
		die "Could not find zyn plugin after zyn build"
	popd


	pushd lmms
	try_mkdir $builddir
	pushd $builddir
	[ -r CMakeCache.txt ] ||
		PKG_CONFIG_PATH=$spa_pkg_config_dir:"$PKG_CONFIG_PATH" cmake \
		-DCMAKE_C_COMPILER=$cexe \
		-DCMAKE_CXX_COMPILER=$cppexe \
		-DCMAKE_INSTALL_PREFIX="$PWD/../$installdir" \
		-DCMAKE_BUILD_TYPE=Release \
		..
	make -j $jobs
	make -j $jobs install
	popd
	popd

	cat >run <<EOF
#!/bin/bash

die() {
	echo "\$@" >&2 ; exit 1
}
run_func()
{
	local install_dir=$PWD/lmms/$installdir
	local bin_lmms="\$install_dir/bin/lmms"
	[ -x "\$bin_lmms" ] || die "Missing LMMS executable \$bin_lmms"
	LMMS_PLUGIN_DIR="$zyn_plugin_dir" \$run_tool \$bin_lmms "\$@"
}

run_func "\$@"

EOF
	chmod +x run
}

do_git()
{
	local depth=$1
	local deptharg='--depth'
	[ "$depth" ] || deptharg=
	git submodule update --init --recursive $deptharg $depth
}

run()
{
	set -e

	if [ "$#" -ne 2 ] && [ "$#" -ne 3 ]
	then
		echo "Usage:"
		echo "  $0 gcc|clang <make-jobs> [shallow-depth]"
		echo "Parameters:"
		echo "  gcc|clang     - Compiler to use"
		echo "  <make-jobs>   - Number of jobs for compiling"
		echo "  shallow-depth - Only if you don't want to clone full"
		echo "                  submodules. Should be >=100."
		echo "Examples:"
		echo "  $0 gcc 4"
		echo "  $0 clang 1 100"
	else
		local comp=$1
		local jobs=$2
		local depth=$3
		do_git "$depth"
		do_build "$comp" "$jobs"

		echo
		echo "Finished"
		echo "Start LMMS using './run'"
	fi
}

run "$@"

