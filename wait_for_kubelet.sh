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

# time before Kubelet restart 
sleep_time=20

# help function to check whether the flannel interface 
# appears among the active interfaces
flannel_is_up() {    
    /usr/sbin/ifconfig | grep flannel    
}

# restart kubelet until the flannel interface is up
sleep ${sleep_time}
while : ; do        
    [[ -z $(flannel_is_up) ]] || break
    sleep ${sleep_time}
    systemctl restart kubelet
done

# a final restart is sometimes needed 
# even if the flannel interface is up 
sleep ${sleep_time}
systemctl restart kubelet
