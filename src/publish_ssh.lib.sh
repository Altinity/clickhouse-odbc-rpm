#!/bin/bash
#
# Publish on remote server via SSH - related functions
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


function publish_ssh()
{
	LOCAL_REPO_TMP_DIR="/tmp/clickhouse-repo"
	REMOTE_REPO_TMP_DIR=$LOCAL_REPO_TMP_DIR

	mkdir -p "$LOCAL_REPO_TMP_DIR"
	rm -rf "$LOCAL_REPO_TMP_DIR/"*

	cp "$RPMS_DIR"/clickhouse*.rpm "$LOCAL_REPO_TMP_DIR"
	if ! createrepo "$LOCAL_REPO_TMP_DIR"; then
		echo "Unable to create repo in $LOCAL_REPO_TMP_DIR"
		exit 1
	fi

	if ! scp -B -r "$LOCAL_REPO_TMP_DIR" $SSH_REPO_USER@$SSH_REPO_SERVER:"$REMOTE_REPO_TMP_DIR"; then
		echo "Unable to copy repo from $LOCAL_REPO_TMP_DIR to $SSH_REPO_USER@$SSH_REPO_SERVER:$REMOTE_REPO_TMP_DIR"
		exit 2
	fi

	if ! ssh $SSH_REPO_USER@$SSH_REPO_SERVER "rm -rf $SSH_REPO_ROOT/$CH_TAG/el$DISTR_MAJOR && mv $REMOTE_REPO_TMP_DIR $SSH_REPO_ROOT/$CH_TAG/el$DISTR_MAJOR"; then
		echo "Unable to move repo on remote server"
		exit 3
	fi
}

