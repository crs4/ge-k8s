#!/bin/bash
# Copyright 2019 CRS4.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy
# of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

#set -o nounset
set -o errexit
set -o pipefail
set -o errtrace

# current path
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# load commons
source "${current_path}/gek8s-common.sh"

# show help
function help() {
    local script_name=$(basename "$0")
    echo -e "\nUsage: ${script_name} [-f gek8s_config_file] [--hosts-file <FILE>] [--hosts <host1>,<host2>,...,<hostn>] [-v p1=v1] ... [-v pn=vn]

    - gek8s_config_file:      defines environment variables to setup the joining process
    - hosts-file              path of the file containing the list of hosts (one host per line)
    - hosts                   list of hosts as a comma-separated value (e.g., h1,h2,...,hn)
    - p1=v1...pn=vn           configuration options (allowed properties: ${gek8s_allowed_config_properties})
    ">&2
}

# prepare pdsh cmd
cmd="${gek8s_node_stop_launcher} kubeadm_config_template=${kubeadm_config_template} ${parameters}"
debug_log "COMMAND: ${cmd}"

# load environment module for running the pdsh parallel shell tool
if ! type pdsh >/dev/null 2>&1 ; then
    module load pdsh
fi

# launch the k8s join on each SGE allocated node
debug_log "Stopping nodes: '${host_list}'"
pdsh -w ${host_list} ${cmd}