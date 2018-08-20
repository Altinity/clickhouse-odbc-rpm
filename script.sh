sudo yum install -y rpm-build redhat-rpm-config createrepo

epel-release
centos-release-scl

cmake3
devtoolset-7

unixODBC-devel
libtool-ltdl-devel

unixODBC
libtool-ltdl


 ODBC_INCLUDE_DIRECTORIES ODBC_LIBRARIES
 LINKER_FLAGS

/usr/include/libiodbc/isql.h
/usr/include/libiodbc/isqlext.h
/usr/include/libiodbc/isqltypes.h
/usr/include/libiodbc/odbcinst.h
/usr/include/libiodbc/sql.h
/usr/include/libiodbc/sqlext.h
/usr/include/libiodbc/sqltypes.h

/usr/lib64/libiodbc.so.2
/usr/lib64/libiodbc.so.2.1.19
/usr/lib64/libiodbcinst.so.2
/usr/lib64/libiodbcinst.so.2.1.19


cmake3 .. -DODBC_INCLUDE_DIRECTORIES=/usr/include/libiodbc -DODBC_LIBRARIES=/usr/lib64/libiodbc.so,/usr/lib64/libiodbcinst.so > cm
cmake3 .. -DODBC_INCLUDE_DIRECTORIES=/usr/include/libodbc -DODBC_LIBRARIES=/usr/lib64/libodbc.so,/usr/lib64/libodbcinst.so  -DCMAKE_CXX_LINK_FLAGS="-Wl,-rpath,/usr/lib64 -L/usr/lib64,-llibodbc,libodbcinst" > cm

-DCMAKE_CXX_LINK_FLAGS="-Wl,-rpath,/usr/local/lib64 -L/usr/local/lib64"

-DLTDL_LIBRARY=/usr/lib64/libltdl.so


cmake3 .. -DODBC_INCLUDE_DIRECTORIES=/usr/include/libodbc -DODBC_LIBRARIES=/usr/lib64/libodbc.so,/usr/lib64/libodbcinst.so  -DCMAKE_CXX_LINK_FLAGS="-Wl,-rpath,/usr/lib64 -L/usr/lib64,-llibodbc,libodbcinst" -DLTDL_LIBRARY=/usr/lib64/libltdl.so > cm

cmake3 .. \
	-DODBC_INCLUDE_DIRECTORIES=/usr/include \
	-DODBC_LIBRARIES=/usr/lib64/libodbc.so \
	-DODBC_LIBRARIES=/usr/lib64/libodbcinst.so  \
	-DCMAKE_CXX_LINK_FLAGS="-Wl,-rpath,/usr/lib64 -L/usr/lib64,-llibodbc,-llibodbcinst" \
	-DLTDL_LIBRARY=/usr/lib64/libltdl.so \
	-DCMAKE_INSTALL_PREFIX:PATH=/tmp \
	> cm3



cmake3 .. \
	-DCMAKE_INSTALL_PREFIX:PATH=/tmp \
	> cm3


export CMAKE=cmake3
export CC=/opt/rh/devtoolset-7/root/usr/bin/gcc
export CXX=/opt/rh/devtoolset-7/root/usr/bin/g++

cmake3 .. -DCMAKE_INSTALL_PREFIX=/tmp/local
make -j6
make install

rpmbuild -v -bb --clean /home/user/rpmbuild/SPECS/clickhouse-odbc.spec



