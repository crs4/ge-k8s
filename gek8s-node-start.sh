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
  echo -e "Usage: ${script_name} -f <GE_K8S_CONFIG_FILE> <GE_K8S_KUBEADM_CONFIG_TEMPLATE>\n
    Parameters:
    - GE_K8S_CONFIG_FILE:               defines environment variables to configure the join of a node
    - GE_K8S_KUBEADM_CONFIG_TEMPLATE:   template of kubeadm config file (actual values come from variables defined on GE_K8S_CONFIG_FILE)\n" >&2  
}

# check number of parameters
if [ "$#" -ne 2 ]; then
    error_log "Illegal number of parameters"
    usage_error
fi

# set configuration file from parameters and check whether it exists
GE_K8S_CONFIG_FILE="${1}"
if [[ ! -f "${GE_K8S_CONFIG_FILE}" ]]; then
    error_log "Configuration file '${GE_K8S_CONFIG_FILE}' doesn't exist!"
    help
    exit 2
fi

# set kubeadm config template file
GE_K8S_KUBEADM_CONFIG_TEMPLATE="${2}"
if [[ ! -f "${GE_K8S_KUBEADM_CONFIG_TEMPLATE}" ]]; then
    error_log "Configuration file '${GE_K8S_KUBEADM_CONFIG_TEMPLATE}' doesn't exist!"
    help
    exit 2
fi

# export all the config vars defined on the GE_K8S_CONFIG_FILE
# in such a way that will available to subsequent scripts
set -a
source "${GE_K8S_CONFIG_FILE}"
set +a

# load environment modules: 
# Docker & Kubernetes versions need to be compatible with the k8s control plane
module load docker-${DOCKER_VERSION}
module load kubernetes-${K8S_VERSION}

# enable IP Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
# enable packets to traverse bridges in order for them to be processed by iptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables

# preload kernel modules required by kubelet
KERNEL_MODULES="ip_vs ip_vs_rr ip_vs_sh ip_vs_wrr nf_conntrack_ipv4 overlay"
for km in ${KERNEL_MODULES} ; do
  modprobe ${km} ;
done

# force cleanup of kubelet configuration
kubeadm reset -f

# (re)start Docker service
systemctl restart docker-${DOCKER_VERSION}

# generate 
kubeadm_config_file="$(mktemp)"
echo "Config: ${kubeadm_config_file}"
envsubst < ${GE_K8S_KUBEADM_CONFIG_TEMPLATE} > "${kubeadm_config_file}"

# config and launch kubelet via kubeadm
kubeadm join --config "${kubeadm_config_file}" --ignore-preflight-errors=all

# Lancia lo script che fa vari sleep e start stop di kubelet
"$(script_dir)/wait_for_kubelet.sh"
