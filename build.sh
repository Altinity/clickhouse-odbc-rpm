#!/bin/bash
#
# Yandex ClickHouse DBMS ODBC driver build script for RHEL based distributions
#
# Tested on:
#  - CentOS 7: 7.5
#
# Copyright (C) 2018 Altinity Ltd

# Git version that we package
CH_VERSION_GIT="${CH_VERSION_GIT:-2018-08-16}"

# Base name of the RPM package
CH_RPM_PACKAGE_NAME="clickhouse-odbc"

# RPM-package name-friendly version of the version
CH_RPM_PACKAGE_VERSION=$(echo $CH_VERSION_GIT | sed -r 's/-+//g')

# User-field
CH_NAME_FULL="clickhouse-odbc-$CH_VERSION_GIT"

# Git https://github.com - relative URI to clone sources from
CH_GIT_URI="yandex/clickhouse-odbc"

# Full path on github to clone sources from
CH_GIT_PATH="https://github.com/$CH_GIT_URI"

# Current work dir
CWD_DIR=$(pwd)

# Source files dir
SRC_DIR="$CWD_DIR/src"

# Where RPMs would be built
RPMBUILD_DIR="$CWD_DIR/rpmbuild"

# Where build process will be run
BUILD_DIR="$RPMBUILD_DIR/BUILD"

# Where build RPM files would be kept
RPMS_DIR="$RPMBUILD_DIR/RPMS/x86_64"

# Where source files would be kept
SOURCES_DIR="$RPMBUILD_DIR/SOURCES"

# Where RPM spec file would be kept
SPECS_DIR="$RPMBUILD_DIR/SPECS"

# Where built SRPM files would be kept
SRPMS_DIR="$RPMBUILD_DIR/SRPMS"

# Where temp files would be kept
TMP_DIR="$RPMBUILD_DIR/TMP"

# Source libraries
. ./src/os.lib.sh
. ./src/publish_packagecloud.lib.sh
. ./src/publish_ssh.lib.sh
. ./src/util.lib.sh

##
##
##
function install_general_dependencies()
{
	banner "Install general dependencies"
	sudo yum install -y git wget curl zip unzip sed
}

##
##
##
function install_rpm_dependencies()
{
        banner "RPM build dependencies"
	sudo yum install -y rpm-build redhat-rpm-config createrepo
}

##
##
##
function install_build_process_dependencies()
{
	banner "Install build tools"
	sudo yum install -y m4 make

	sudo yum install -y epel-release
	sudo yum install -y cmake3

	sudo yum install -y centos-release-scl
	sudo yum install -y devtoolset-7


	banner "Install CH dev dependencies"
	sudo yum install -y unixODBC libtool-ltdl
	sudo yum install -y unixODBC-devel libtool-ltdl-devel
}

##
##
##
function install_workarounds()
{
	banner "Install workarounds"

	# Now all workarounds are included into CMAKE_OPTIONS and MAKE_OPTIONS
}

##
## Install all required components before building RPMs
##
function install_dependencies()
{
	banner "Install dependencies"

	install_general_dependencies
	install_rpm_dependencies

	install_build_process_dependencies

	install_workarounds
}

##
## Prepare $RPMBUILD_DIR/SOURCES/ClickHouse-$CH_VERSION-$CH_TAG.zip file
##
function prepare_sources()
{
	banner "Ensure SOURCES dir is in place"
	mkdirs

	echo "Clean sources dir"
	rm -rf "$SOURCES_DIR/$CH_NAME_FULL"

	cd $SOURCES_DIR

	echo "Cloning from $CH_GIT_PATH  into $SOURCES_DIR/$CH_NAME_FULL"

	# Go older way because older versions of git (CentOS 6.9, for example) do not understand new syntax of branches etc
	git clone "$CH_GIT_PATH" "$CH_NAME_FULL"

	cd "$CH_NAME_FULL"

	echo "Checkout specific tag $CH_VERSION_GIT"
	git checkout "$CH_VERSION_GIT"

	echo "Update submodules"
	git submodule update --init --recursive

	cd "$SOURCES_DIR"

	echo "Move files into .tar.gz"
	tar -zcf "${CH_NAME_FULL}.tar.gz" "$CH_NAME_FULL"

	echo "Ensure .tar.gz file is available"
	ls -l "${CH_NAME_FULL}.tar.gz"

	cd "$CWD_DIR"
}

##
##
##
function build_spec_file()
{
	banner "Ensure SPECS dir is in place"
	mkdirs

	banner "Build .spec file"

	CMAKE_OPTIONS="${CMAKE_OPTIONS}"
		  
	MAKE_OPTIONS="${MAKE_OPTIONS}"

	# Create spec file from template
	cat "$SRC_DIR/clickhouse.spec.in" | sed \
		-e "s|@CH_VERSION_GIT@|$CH_VERSION_GIT|" \
		-e "s|@CH_RPM_PACKAGE_NAME@|$CH_RPM_PACKAGE_NAME|" \
		-e "s|@CH_RPM_PACKAGE_VERSION@|$CH_RPM_PACKAGE_VERSION|" \
		-e "s|@CH_NAME_FULL@|$CH_NAME_FULL|" \
		-e "s|@RPMBUILD_DIR@|$RPMBUILD_DIR|" \
		-e "s|@TMP_DIR@|$TMP_DIR|" \
		-e "s|@CMAKE_OPTIONS@|$CMAKE_OPTIONS|" \
		-e "s|@MAKE_OPTIONS@|$MAKE_OPTIONS|" \
		> "$SPECS_DIR/clickhouse.spec"

	banner "Looking for .spec file"
	ls -l "$SPECS_DIR/clickhouse.spec"
}


##
## Build RPMs
##
function build_RPMs()
{
	banner "Ensure build dirs are in place"
	mkdirs

	banner "Setup path to compilers"
	export CMAKE=cmake3
	export CC=/opt/rh/devtoolset-7/root/usr/bin/gcc
	export CXX=/opt/rh/devtoolset-7/root/usr/bin/g++
	#export CXXFLAGS="${CXXFLAGS} -Wno-maybe-uninitialized"

	echo "CMAKE=$CMAKE"
	echo "CC=$CC"
	echo "CXX=$CXX"

	echo "cd into $CWD_DIR"
	cd "$CWD_DIR"

	banner "Build RPMs"
	rpmbuild -v -bs "$SPECS_DIR/clickhouse.spec"
	rpmbuild -v -bb "$SPECS_DIR/clickhouse.spec"
	banner "Build RPMs completed"

	# Display results
	list_RPMs
	list_SRPMs
}

##
## Build packages:
## 1. clean folders
## 2. prepare sources
## 3. build spec file
## 4. build RPMs
##
function build_packages()
{
	banner "Ensure build dirs are in place"
	mkdirs

	echo "Clean up after previous run"
	rm -f "$RPMS_DIR"/clickhouse*
	rm -f "$SRPMS_DIR"/clickhouse*
	rm -f "$SPECS_DIR"/clickhouse.spec

	banner "Create RPM packages"
	
	# Prepare $SOURCES_DIR/ClickHouse-$CH_VERSION-$CH_TAG.zip file
	prepare_sources

	# Build $SPECS_DIR/clickhouse.spec file
	build_spec_file
 
	# Compile sources and build RPMS
	build_RPMs
}

##
##
##
function usage()
{
	# disable commands print
	set +x

	echo "Usage:"
	echo
	echo "./build.sh version        - display default version to build"
	echo
	echo "./build.sh all            - most popular point of entry - the same as idep_all"
	echo
	echo "./build.sh idep_all       - install dependencies from RPMs, download CH sources and build RPMs"
	echo "./build.sh bdep_all       - build dependencies from sources, download CH sources and build RPMs"
	echo "                            !!! YOU MAY NEED TO UNDERSTAND INTERNALS !!!"
	echo
	echo "./build.sh install_deps   - just install dependencies (do not download sources, do not build RPMs)"
	echo "./build.sh build_deps     - just build dependencies (do not download sources, do not build RPMs)"
	echo "./build.sh src            - just prepare sources (download with submodules and pack)"
	echo "./build.sh spec           - just create SPEC file (do not download sources, do not build RPMs)"
	echo "./build.sh packages       - download sources, create SPEC file and build RPMs (do not install dependencies)"
	echo "./build.sh rpms           - just build RPMs from sources in archive (tar.gz)"
	echo "                            (do not download sources, do not create SPEC file, do not install dependencies)"
	echo "MYSRC=yes ./build.sh rpms - just build RPMs from unpacked sources - most likely you have modified them"
	echo "                            (do not download sources, do not create SPEC file, do not install dependencies)"
	echo
	echo "./build.sh publish packagecloud <packagecloud USER ID> - publish packages on packagecloud as USER"
	echo "./build.sh delete packagecloud <packagecloud USER ID>  - delete packages on packagecloud as USER"
	echo
	echo "./build.sh publish ssh - publish packages via SSH"
	
	exit 0
}

if [ -z "$1" ]; then
	usage
fi

COMMAND="$1"

if [ "$COMMAND" == "version" ]; then
	echo "$CH_VERSION_GIT"

elif [ "$COMMAND" == "all" ]; then
	ensure_os_rpm_based
	set_print_commands
	install_dependencies
	build_packages

elif [ "$COMMAND" == "idep_all" ]; then
	ensure_os_rpm_based
	set_print_commands
	install_dependencies
	build_packages

elif [ "$COMMAND" == "bdep_all" ]; then
	ensure_os_rpm_based
	set_print_commands
	build_dependencies
	build_packages

elif [ "$COMMAND" == "install_deps" ]; then
	ensure_os_rpm_based
	set_print_commands
	install_dependencies

elif [ "$COMMAND" == "build_deps" ]; then
	ensure_os_rpm_based
	set_print_commands
	build_dependencies

elif [ "$COMMAND" == "src" ]; then
	set_print_commands
	prepare_sources

elif [ "$COMMAND" == "spec" ]; then
	set_print_commands
	build_spec_file

elif [ "$COMMAND" == "packages" ]; then
	ensure_os_rpm_based
	set_print_commands
	build_packages

elif [ "$COMMAND" == "rpms" ]; then
	ensure_os_rpm_based
	set_print_commands
	build_RPMs

elif [ "$COMMAND" == "publish" ]; then
	PUBLISH_TARGET="$2"

	ensure_os_rpm_based
	if [ "$PUBLISH_TARGET" == "packagecloud" ]; then
		# run publish script with all the rest of CLI params
		publish_packagecloud ${*:3}

	elif [ "$PUBLISH_TARGET" == "ssh" ]; then
		publish_ssh

	else
		echo "Unknown publish target"
		usage
	fi

elif [ "$COMMAND" == "delete" ]; then
	PUBLISH_TARGET="$2"
	if [ "$PUBLISH_TARGET" == "packagecloud" ]; then
		# run publish script with all the rest of CLI params
		publish_packagecloud_delete ${*:3}

	elif [ "$PUBLISH_TARGET" == "ssh" ]; then
		echo "Not supported yet"
	else
		echo "Unknown publish target"
		usage
	fi

else
	# unknown command
	echo "Unknown command: $COMMAND"
	usage
fi

