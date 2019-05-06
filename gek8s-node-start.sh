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

function help() {
  local script_name=$(basename "$0")  
  echo -e "\nUsage: ${script_name} [-f gek8s_config_file] [-v p1=v1] ... [-v pn=vn]

    - gek8s_config_file:      defines environment variables to configure the gek8s join
    - p1=v1...pn=vn           configuration options (allowed properties: ${gek8s_allowed_config_properties})
    ">&2
}

# check whether docker is installed and load the right version if not
if ! type docker >/dev/null 2>&1 ; then
  module load docker-${docker_version}
fi
# check whether Kubernetes is installed and load the right version if not
if ! type kubectl >/dev/null 2>&1 ; then
  module load kubernetes-${k8s_version}
fi

# enable IP Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
# enable packets to traverse bridges in order for them to be processed by iptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables

# preload kernel modules required by kubelet
kernel_modules="ip_vs ip_vs_rr ip_vs_sh ip_vs_wrr nf_conntrack_ipv4 overlay"
for km in ${kernel_modules} ; do
  modprobe ${km} ;
done

# force cleanup of kubelet configuration
kubeadm reset -f

# (re)start Docker service
systemctl restart docker

# generate 
kubeadm_config_file="$(mktemp)"
envsubst < ${GE_K8S_KUBEADM_CONFIG_TEMPLATE} > "${kubeadm_config_file}"

# config and launch kubelet via kubeadm
kubeadm join --config "${kubeadm_config_file}" --ignore-preflight-errors=all

# wait until kubelet is up and running
"${current_path}/wait_for_kubelet.sh"
