#!/bin/bash

mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS,TMP}
cp clickhouse-odbc.spec ~/rpmbuild/SPECS
wget https://github.com/yandex/clickhouse-odbc/archive/2018-08-16.tar.gz  --output-document=~/rpmbuild/SOURCES/clickhouse-odbc.tar.gz
