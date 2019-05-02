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

set -o nounset
set -o errexit
set -o pipefail
set -o errtrace

# initialize the bash environment if needed
# . /Archive/Software/Modules/3.2.10/init/bash

# portable version of abspath
function abspath() {
    local path="${*}"
    
    if [[ -d "${path}" ]]; then
        echo "$( cd "${path}" >/dev/null && pwd )"
    else
        echo "$( cd "$( dirname "${path}" )" >/dev/null && pwd )/$(basename "${path}")"
    fi
}

function script_dir() {
  echo "$(dirname $(abspath ${BASH_SOURCE[0]}))"
}

function log() {
    echo -e "${@}" >&2
}

function debug_log() {
    if [[ -n "${DEBUG:-}" ]]; then
        echo -e "DEBUG: ${@}" >&2
    fi
}

function error_log() {
    echo -e "ERROR: ${@}" >&2
}

function error_trap() {
    error_log "Error at line ${BASH_LINENO[1]} running the following command:\n\n\t${BASH_COMMAND}\n\n"
    error_log "Stack trace:"
    for (( i=1; i < ${#BASH_SOURCE[@]}; ++i)); do
        error_log "$(printf "%$((4*$i))s %s:%s\n" " " "${BASH_SOURCE[$i]}" "${BASH_LINENO[$i]}")"
    done
    exit 2
}

trap error_trap ERR

function usage_error() {
    if [[ $# > 0 ]]; then
        echo -e "ERROR: ${@}" >&2
    fi
    help
    exit 2
}

function help() {
    local script_name=$(basename "$0")
    echo -e "\nUsage: ${script_name}

    The following variables must be defined in your environment:

     - GE_K8S_CONFIG_FILE:               defines environment variables to configure the ge-k8s join">&2
}

# set default GE_K8S_CONFIG_FILE
config_file=${GE_K8S_CONFIG_FILE:-"$(script_dir)/ge_k8s_config.sh"}

# export all the config vars defined on the GE_K8S_CONFIG_FILE
# in such a way that will available to subsequent scripts
set -a
source "${GE_K8S_CONFIG_FILE}"
set +a

# load environment modules: 
# Docker & Kubernetes versions need to be compatible with the k8s control plane
module load docker-${DOCKER_VERSION}
module load kubernetes-${K8S_VERSION}

# force cleanup of kubelet configuration
kubeadm reset -f

# (re)start Docker service
systemctl stop docker-${DOCKER_VERSION}
systemctl stop kubelet-${K8S_VERSION}

# teardown network interfaces
ifconfig flannel.1 down
ifconfig cni0 down
ifconfig docker0 down

# clean registered iptables rules
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X