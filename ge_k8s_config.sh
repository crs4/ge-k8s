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

# set Docker version
DOCKER_VERSION="18.06.1"

# set Kubernetes version
K8S_VERSION="v1.12.7"

# set k8s API server endpoint (e.g., 172.30.64.1:6443)
K8S_API_ENDPOINT=

# set k8s token
K8S_KUBEADM_TOKEN=

# set labels of joining nodes (e.g., l1,l2,l3, etc.)
K8S_NODE_LABELS=