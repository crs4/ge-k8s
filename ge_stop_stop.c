/** 
 * Copyright 2019 CRS4.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy
 * of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include <signal.h>

main(int argc, char *argv[])
{     
     // switch to the root user by setting UID to 0
     if (setuid(0))
     {
          perror("Unable to set UID to 0");
          return -1;
     }
     // run node boostrap script as root (needed by kubeadm and kubelet)
     system("<PATH_TO_K8S_NODE_STOP_SCRIPT> <PATH_TO_KUBERNETES_DEFAULTS>");
}
