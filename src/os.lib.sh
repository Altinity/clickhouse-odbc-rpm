#!/bin/bash
#
# OS - related functions
#
# Copyright (C) 2017 Altinity Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


##
## Print error message and exit with exit code 1
##
function os_unsupported()
{
	echo "This OS is not supported. However, you can set 'OS' and 'DISTR' ENV vars manually."
	echo "Can't continue, exit"

	exit 1
}

##
## is OS YUM-based?
##
function os_yum_based()
{
	[ "$OS" == "rhel" ] || [ "$OS" == "centos" ] || [ "$OS" == "fedora" ] || [ "$OS" == "ol" ]
}

##
## is OS Red Hat Enterprise Linux?
##
function os_rhel()
{
	[ "$OS" == "rhel" ] || [ "$OS" == "redhatenterpriseserver" ]
}

##
## is OS Oracle Linux?
##
function os_ol()
{
	[ "$OS" == "ol" ] 
}

##
## is OS CenOS?
##
function os_centos()
{
	if [ -z ${1+x} ]; then
		# "param 1 is unset
		[ "$OS" == "centos" ]
	else
		# params 1 is set
		[ "$OS" == "centos" ] && [ "$DISTR_MAJOR" == "$1" ]
	fi
}

##
##
##
function os_centos_6()
{
	[ os_centos ] && [ "$DISTR_MAJOR" == 6 ]
}

##
##
##
function os_centos_7()
{
	[ os_centos ] && [ "$DISTR_MAJOR" == 7 ]
}

##
## is OS Fedora?
##
function os_fedora()
{
	[ "$OS" == "fedora" ]
}

##
## is OS Ubuntu?
##
function os_ubuntu()
{
	[ "$OS" == "ubuntu" ]
}

##
## is OS APT-based?
##
function os_apt_based()
{
	[ "$OS" == "ubuntu" ] || [ "$OS" == "linuxmint" ]
}

##
## is OS RPM-based?
##
function os_rpm_based()
{
	os_yum_based
}

##
## Detect OS. Results are written into
## $OS - string lowercased codename ex: centos, linuxmint
## $DISTR_MAJOR - int major version ex: 7 for CentOS 7.3, 18 for Linux Mint 18
## $DISTR_MINOR - int minor version ex: 3 for centos 7.3, Empty "" for Linux Mint 18
##
function os_detect()
{
	if [ -n "$OS" ] && [ -n "$DISTR_MAJOR" ]; then
		# looks like all is explicitly set
		echo "OS specified: $OS $DISTR_MAJOR $DISTR_MINOR"
		return
	fi

	# OS or DIST are NOT specified
	# let's try to figure out what exactly are we running on

	if [ -e /etc/os-release ]; then
		# nice, can simply source OS specification
		. /etc/os-release
			
		# OS=linuxmint
		OS=${ID}

		# need to parse "18.2"
		# DISTR_MAJOR=18
		# DISTR_MINOR=2
		DISTR_MAJOR=`echo ${VERSION_ID} | awk -F '.' '{ print $1 }'`
		DISTR_MINOR=`echo ${VERSION_ID} | awk -F '.' '{ print $2 }'`

	elif command -v lsb_release > /dev/null; then
		# something like Ubuntu

		# need to parse "Distributor ID:	LinuxMint"
		# OS=linuxmint
		OS=`lsb_release -i | cut -f2 | awk '{ print tolower($1) }'`

		# need to parse "Release:	18.2"
		# DISTR_MAJOR=18
		# DISTR_MINOR=2
		DISTR_MAJOR=`lsb_release -r | cut -f2 | awk -F '.' '{ print $1 }'`
		DISTR_MINOR=`lsb_release -r | cut -f2 | awk -F '.' '{ print $2 }'`

	elif [ -e /etc/centos-release ]; then
		OS='centos'

		# need to parse "CentOS release 6.9 (Final)"
		# DISTR_MAJOR=6
		# DISTR_MINOR=9
       		DISTR_MAJOR=`cat /etc/centos-release | awk '{ print $3 }' | awk -F '.' '{ print $1 }'`
       		DISTR_MINOR=`cat /etc/centos-release | awk '{ print $3 }' | awk -F '.' '{ print $2 }'`

	elif [ -e /etc/fedora-release ]; then
		OS='fedora'

		# need to parse "Fedora release 26 (Twenty Six)"
		# DISTR_MAJOR=26
		# DISTR_MINOR=""
		DISTR_MAJOR=`cut -f3 --delimiter=' ' /etc/fedora-release`
		DISTR_MINOR=""

	elif [ -e /etc/redhat-release ]; then
		# need to parse "CentOS Linux release 7.3.1611 (Core)"
		# OS=centos
		OS=`cat /etc/redhat-release  | awk '{ print tolower($1) }'`

		# need to parse "CentOS Linux release 7.3.1611 (Core)"
		# DISTR_MAJOR=7
		# DISTR_MINOR=3
       		DISTR_MAJOR=`cat /etc/redhat-release | awk '{ print $4 }' | awk -F '.' '{ print $1 }'`
       		DISTR_MINOR=`cat /etc/redhat-release | awk '{ print $4 }' | awk -F '.' '{ print $2 }'`

	else
		# do not know this OS
		os_unsupported
	fi

	echo "OS detected: $OS $DISTR_MAJOR $DISTR_MINOR"
}

##
##
##
function ensure_os_rpm_based()
{
	os_detect
	if ! os_rpm_based; then
		echo "We need RPM-based OS in order to build RPM packages."
		exit 1
	else
		echo "RPM-based OS detected, continue"
	fi
}

