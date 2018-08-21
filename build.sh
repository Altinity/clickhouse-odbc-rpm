#!/bin/bash

# Current work dir
CWD_DIR=$(pwd)

# Where RPMs would be built
RPMBUILD_DIR="/home/user/rpmbuild"

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

CH_VERSION="${CH_VERSION:-2018-08-16}"

sudo yum install -y rpm-build redhat-rpm-config createrepo
sudo yum install -y epel-release
sudo yum install -y centos-release-scl
sudo yum install -y cmake3 devtoolset-7
sudo yum install -y unixODBC libtool-ltdl
sudo yum install -y unixODBC-devel libtool-ltdl-devel
sudo yum install -y wget

mkdir -p $RPMBUILD_DIR/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS,TMP}
cp clickhouse-odbc.spec $SPECS_DIR
cd $SOURCES_DIR

echo "Cloning from github"

# Go older way because older versions of git (CentOS 6.9, for example) do not understand new syntax of branches etc
# Clone specified branch with all submodules into $SOURCES_DIR/ClickHouse-$CH_VERSION-$CH_TAG folder
echo "Clone clickhouse-odbc repo"
git clone "https://github.com/yandex/clickhouse-odbc" "clickhouse-odbc"

cd "clickhouse-odbc"

echo "Checkout specific tag $CH_VERSION"
git checkout "$CH_VERSION"

echo "Update submodules"
git submodule update --init --recursive

cd ..
echo "Move files into .zip with minimal compression"
tar -zcf clickhouse-odbc.tar.gz clickhouse-odbc

rpmbuild -v -bb --clean /home/user/rpmbuild/SPECS/clickhouse-odbc.spec
rpmbuild -v -bs --clean /home/user/rpmbuild/SPECS/clickhouse-odbc.spec

