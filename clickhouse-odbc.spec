 
%define name	  clickhouse-odbc
%define version	  20180820
%define release	  1

%define _topdir             /home/user/rpmbuild
%define _tmppath            %{_topdir}/TMP
%define tmp_buildroot       %{_tmppath}/%{name}-%{version}
%define make_install_prefix /usr/local

# disable debuginfo packages
%define debug_package %{nil}

%if 0%{?rhel} != 0
%define dist .el%{rhel}
%endif

Summary:   Yandex ClickHouse DBMS ODBC driver
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    %{name}.tar.gz
License:   Apache License 2.0
Group:     Applications/Databases
BuildRoot: %{_tmppath}/%{name}-%{version}-build
Prefix:    /usr/local
Vendor:    Yandex
Packager:  Altinity
Url:       https://clickhouse.yandex/
Requires:  unixODBC
Requires:  libtool-ltdl

# build requirements
BuildRequires: epel-release
BuildRequires: centos-release-scl
BuildRequires: cmake3
BuildRequires: devtoolset-7
BuildRequires: unixODBC-devel
BuildRequires: libtool-ltdl-devel
 
%description
ClickHouse is an open-source column-oriented database management
system that allows generating analytical data reports in real time.
 
%prep
%setup -q -n clickhouse-odbc
 
%build
# clean build folder
rm -rf build
mkdir build

# build with install prefix

export CMAKE=cmake3
export CC=/opt/rh/devtoolset-7/root/usr/bin/gcc
export CXX=/opt/rh/devtoolset-7/root/usr/bin/g++

# install all files into BUILDROOT/tmpdirname/%{make_install_prefix}
cd build
cmake3 .. -DCMAKE_INSTALL_PREFIX:PATH=%{tmp_buildroot}%{make_install_prefix} -DCMAKE_BUILD_TYPE:STRING=Release
make -j $(nproc || sysctl -n hw.ncpu || echo 4)
make install

echo "Make completed."
read -p "Press enter to continue"
 
%install
echo "Install section"
read -p "Press enter to continue"

cp -r %{tmp_buildroot}/* %{buildroot}/

echo "Install completed"
read -p "Press enter to continue"

%clean
echo "Clean Section"
read -p "Press enter to continue"
%{__rm} -rf %{buildroot}
%{__rm} -rf %{tmp_buildroot}
echo "Clean Section Completed"
read -p "Press enter to continue"
 
%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig
 
%files
# just include the whole directory
%defattr(-,root,root)
%{make_install_prefix}

%changelog
* Tue Aug 21 2018 Vladislav Klimenko
- Initial version 2018-08-16

