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

# set -o nounset
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

# force cleanup of kubelet configuration
kubeadm reset -f

# (re)start Docker service
systemctl stop docker
systemctl stop kubelet

# teardown network interfaces
ifconfig flannel.1 down
ifconfig cni0 down
ifconfig docker0 down

# clean registered iptables rules
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X