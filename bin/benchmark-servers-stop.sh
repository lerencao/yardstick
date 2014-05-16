#!/bin/bash

#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

#
# Script that stops BenchmarkServer on remote machines.
# This script expects first argument to be a path to run properties file which contains
# the list of remote nodes to start server on and the list of configurations.
#

# Define script directory.
SCRIPT_DIR=$(cd $(dirname "$0"); pwd)

CONFIG_INCLUDE=$1

if [ "${CONFIG_INCLUDE}" == "" ]; then
    CONFIG_INCLUDE=${SCRIPT_DIR}/../config/benchmark.properties
    echo "Properties file is not defined, using default one: 'config/benchmark.properties'."
    echo
fi

if [ ! -f $CONFIG_INCLUDE ]; then
    echo $0", ERROR:"
    echo "Configuration file not found."
    exit 1
fi

shift

CONFIG_TMP=`mktemp tmp.XXXXXXXX`

cp $CONFIG_INCLUDE $CONFIG_TMP
chmod +x $CONFIG_TMP

. $CONFIG_TMP
rm $CONFIG_TMP

# Define user to establish remote ssh session.
if [ "${REMOTE_USER}" == "" ]; then
    REMOTE_USER=$(whoami)
fi

if [ "${HOSTS}" == "" ]; then
    echo $0", ERROR:"
    echo "Benchmark hosts (HOSTS) is not defined."
    exit 1
fi

if [ "${REMOTE_USER}" == "" ]; then
    echo $0", ERROR:"
    echo "Remote user (REMOTE_USER) is not defined."
    exit 1
fi

IFS=',' read -ra hosts0 <<< "${HOSTS}"
for host_name in "${hosts0[@]}";
do
    `ssh -o PasswordAuthentication=no ${REMOTE_USER}"@"${host_name} pkill -9 -f "Dyardstick.bench"`
done
