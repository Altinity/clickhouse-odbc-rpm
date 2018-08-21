#!/bin/bash

sudo yum install -y rpm-build redhat-rpm-config createrepo
sudo yum install -y epel-release
sudo yum install -y centos-release-scl
sudo yum install -y cmake3 devtoolset-7
sudo yum install -y unixODBC libtool-ltdl
sudo yum install -y unixODBC-devel libtool-ltdl-devel
sudo yum install -y wget

mkdir -p /home/user/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS,TMP}
cp clickhouse-odbc.spec /home/user/rpmbuild/SPECS
cd /home/user/rpmbuild/SOURCES/

echo "Cloning from github"

# Go older way because older versions of git (CentOS 6.9, for example) do not understand new syntax of branches etc
# Clone specified branch with all submodules into $SOURCES_DIR/ClickHouse-$CH_VERSION-$CH_TAG folder
echo "Clone clickhouse-odbc repo"
git clone "https://github.com/yandex/clickhouse-odbc" "clickhouse-odbc"

cd "clickhouse-odbc"

echo "Checkout specific tag v${CH_VERSION}-${CH_TAG}"
git checkout "2018-08-16"

echo "Update submodules"
git submodule update --init --recursive

cd ..
echo "Move files into .zip with minimal compression"
tar -zcf clickhouse-odbc.tar.gz clickhouse-odbc

rpmbuild -v -bb --clean /home/user/rpmbuild/SPECS/clickhouse-odbc.spec
rpmbuild -v -bs --clean /home/user/rpmbuild/SPECS/clickhouse-odbc.spec

