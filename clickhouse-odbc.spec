 
%define name	    clickhouse-odbc
%define version	    20180820
%define release	    1


%define _topdir             /home/user/rpmbuild
%define _tmppath            %{_topdir}/TMP
%define tmp_buildroot       %{_tmppath}/%{name}-%{version}
%define make_install_prefix /tmp/local

# disable debuginfo packages
%define debug_package %{nil}
 
Summary:   GNU wget
License:   GPL
Name:      %{name}
Version:   %{version}
Release:   %{release}
Source:    %{name}.tar.gz
Prefix:    /usr/local
Group:     Development/Tools
BuildRoot: %{_tmppath}/%{name}-%{version}-build
 
%description
The GNU wget program downloads files from the Internet using the command-line.
 
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
make -j6
make install

echo "Make completed."
read -p "Press enter to continue"
 
%install
echo "Install section"
read -p "Press enter to continue"

cp -r %{tmp_buildroot}/* %{buildroot}/

echo "Install completed"
read -p "Press enter to continue"
 
%files
# just include the whole directory
%defattr(-,root,root)
%{make_install_prefix}

