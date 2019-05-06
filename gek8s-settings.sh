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

# default machine files path
gek8s_machine_file="${TMPDIR:-'/tmp/'}machines"

# set default gek8s_node_start_launcher
gek8s_node_start_launcher="${current_path}/gek8s-node-start-launcher"

# set default gek8s_node_start_launcher
gek8s_node_stop_launcher="${current_path}/gek8s-node-stop-launcher"

# set default gek8s_node_start
gek8s_node_start_script="${current_path}/gek8s-node-start.sh"

# set default gek8s_node_stop
gek8s_node_stop_script="${current_path}/gek8s-node-stop.sh"

# supported configuration properties
gek8s_allowed_config_properties="docker_version k8s_version kubeadm_config_template k8s_api_endpoint k8s_kubeadm_token k8s_node_labels"

# set default gek8s_config_file
gek8s_config_file="${current_path}/config.sh"
