#!/bin/bash
#
# Publish on Packagecloud.com - related functions
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

function publish_packagecloud_distro_version_id()
{
	# EL6  - 27
	# EL7  - 140
	# FC25 - 179
	# FC26 - 184
	# JAVA - 167
	# Ubuntu 14.04 LTS Trusty Tahr   - 20
	# Ubuntu 16.04 LTS Xenial Xerus  - 165
	# Ubuntu 18.04 LTS Bionic Beaver - 190
	# Debian  9 stretch - 149
	# Debian 10 buster  - 150


	if os_centos; then
		if [ $DISTR_MAJOR == 6 ]; then
			return 27
		elif [ $DISTR_MAJOR == 7 ]; then
			return 140
		else
			echo "Unknown centos distro"
			exit 1
		fi
	elif os_fedora; then
		if [ $DISTR_MAJOR == 25 ]; then
			return 179
		elif [ $DISTR_MAJOR == 26 ]; then
			return 184
		else
			echo "Unknown fedora distro"
			exit 1
		fi
	elif os_ubuntu; then
		if [ $DISTR_MAJOR == 14 ] && [ "${DISTR_MINOR}" == "04" ]; then
			return 20
		elif [ $DISTR_MAJOR == 16 ] && [ "${DISTR_MINOR}" == "04" ]; then
			return 165
		elif [ $DISTR_MAJOR == 18 ] && [ "${DISTR_MINOR}" == "04" ]; then
			return 190
		else
			echo "Unknown ubuntu distro"
			exit 1
		fi
	fi

	# not found what OS are we running on
	echo "Unknown OS"
	exit 1
}

function publish_packagecloud_file()
{
	# Packagecloud user id. Ex.: 123ab45678c9012d3e4567890abcdef1234567890abcdef1
	PACKAGECLOUD_ID=$1

	# Path inside user's repo on packagecloud. Ex.: altinity/clickhouse
	PACKAGECLOUD_PATH=$2

	# Packagecloud distro version id. See packagecloud_distro_version_id() function. Ex.: 27
	DISTRO_VERSION_ID=$3

	# Path to file to publish
	FILE_PATH=$4

	echo -n "Publishing file: $FILE_PATH"
	if curl --show-error --silent --output /dev/null -X POST https://$PACKAGECLOUD_ID:@packagecloud.io/api/v1/repos/$PACKAGECLOUD_PATH/packages.json \
		-F "package[distro_version_id]=$DISTRO_VERSION_ID" \
		-F "package[package_file]=@$FILE_PATH"; 
	then
		echo "...OK"
	else
		echo "...FAILED"
	fi
}

function publish_packagecloud_files_list()
{
	# Packagecloud user id. Ex.: 123ab45678c9012d3e4567890abcdef1234567890abcdef1
	PACKAGECLOUD_ID=$1

	# Path inside user's repo on packagecloud. Ex.: altinity/clickhouse
	PACKAGECLOUD_PATH="altinity/clickhouse"

	# Packagecloud distro version id. See packagecloud_distro_version_id() function. Ex.: 27
	publish_packagecloud_distro_version_id
	DISTRO_VERSION_ID=$?

	echo "Publishing as $PACKAGECLOUD_ID to '$PACKAGECLOUD_PATH' for distro $DISTRO_VERSION_ID"

	if [ -n "$2" ]; then
		# Have args specified. Treat it as a list of files to publish
		for FILE in ${@:2}; do
			publish_packagecloud_file $PACKAGECLOUD_ID $PACKAGECLOUD_PATH $DISTRO_VERSION_ID $FILE
		done
	else
		echo "Do not have any files specified. This is not particularly correct, may be even an error"
	fi
}

function publish_packagecloud()
{
	# Packagecloud user id. Ex.: 123ab45678c9012d3e4567890abcdef1234567890abcdef1
	PACKAGECLOUD_ID=$1

	# Path inside user's repo on packagecloud. Ex.: altinity/clickhouse
	PACKAGECLOUD_PATH="altinity/clickhouse"

	# Packagecloud distro version id. See packagecloud_distro_version_id() function. Ex.: 27
	publish_packagecloud_distro_version_id
	DISTRO_VERSION_ID=$?

	if [ -n "$2" ]; then
		# Have args specified. Treat it as a list of files to publish
		publish_packagecloud_files_list $PACKAGECLOUD_ID ${@:2}
	else
		# Do not have any files specified. Publish RPMs from RPMS path
		publish_packagecloud_files_list $PACKAGECLOUD_ID $(ls "$RPMBUILD_DIR"/RPMS/x86_64/clickhouse*.rpm)
	fi
}

function publish_packagecloud_delete()
{
	# Packagecloud user id. Ex.: 123ab45678c9012d3e4567890abcdef1234567890abcdef1
	PACKAGECLOUD_ID=$1

	if [ -n "$2" ]; then
		# Have args specified. Treat it as a list of files to publish
		for FILE in ${@:2}; do

			# make https://123456eae45643234234234234234234534aehaeh234ahdh:@packagecloud.io/api/v1/repos/altinity/clickhouse/PATH/TO/FILE
			# which is the URL used for deletetion,
			# out of
			# https://packagecloud.io/altinity/clickhouse/packages/PATH/TO/FILE 
			# which is URL presented by packagecloud in their GUI
			# (don't ask, why are those URIs different, just replace what is needed)
			URL="${FILE/packagecloud.io/$PACKAGECLOUD_ID:@packagecloud.io/api/v1/repos}"
			URL="${URL/packages\//}"
			echo "Deleting"
			echo "file: $FILE"
			echo "URL : $URL"
			echo -n "Delete result"
			if curl --show-error --silent --output /dev/null -X DELETE "$URL"; then
				echo "...OK"
			else
				echo "...FAILED"
			fi
		done
	else
		echo "Please specify URL to FILE to delete"
	fi

}

