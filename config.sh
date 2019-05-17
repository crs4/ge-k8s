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

# current path
current_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# set Docker version
docker_version="18.06.1"

# set Kubernetes version
k8s_version="v1.12.7"

# set default gs_k8s_kubeadm_config
kubeadm_config_template="${current_path}/gs-k8s-kubeadm-config.template.yml"

# set k8s API server endpoint (e.g., 172.30.64.1:6443)
k8s_api_endpoint="172.30.10.101:6443"

# set k8s token
k8s_kubeadm_token="zv18vk.q30uidedqilsdklj"

# set labels of joining nodes (e.g., l1,l2,l3, etc.)
k8s_node_labels="transient-node"

TMPDIR="/tmp"
