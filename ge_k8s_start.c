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

void print_usage_and_exit(void)
{
     char *help = "\nusage: ge_k8s_start <GE_K8S_CONFIG_FILE> <GE_K8S_KUBEADM_CONFIG_TEMPLATE>\n\n"
                  "The following variables must be defined in your environment:\n"
                  "\n- GE_K8S_NODE_START_SCRIPT:         path to the script to bootstrap a k8s node"
                  "\n- GE_K8S_CONFIG_FILE:               defines environment variables to configure the join of a node"
                  "\n- GE_K8S_KUBEADM_CONFIG_TEMPLATE:   template of kubeadm config file (actual values come from variables defined on GE_K8S_CONFIG_FILE)\n\n";
     fprintf(stderr, "%s", help);
     exit(EXIT_FAILURE);
}


int main(int argc, char *argv[])
{
     if (argc != 4)
     {
          perror("Invalid number of arguments");
          print_usage_and_exit();
     }

     // log parameters
     fprintf(stderr,"\nUsing parameters: ");     
     fprintf(stderr,"\n- GE_K8S_NODE_START_SCRIPT: %s", argv[1]);
     fprintf(stderr,"\n- GE_K8S_CONFIG_FILE: %s", argv[2]);
     fprintf(stderr,"\n- GE_K8S_KUBEADM_CONFIG_TEMPLATE: %s", argv[3]);
     
     // switch to the root user by setting UID to 0
     fprintf(stderr, "%s", "\n\nChanging UID... ");
     if (setuid(0))
     {
          perror("Unable to set UID to 0\n");
          return -1;
     }
     fprintf(stderr, "%s","DONE\n");

     // build boostrap command
     char cmd[1024];
     snprintf(cmd, sizeof(cmd), "%s %s %s", argv[1], argv[2], argv[3]);
     // run node boostrap command as root
     fprintf(stderr, "%s", "\n\nStarting nodes... ");
     system(cmd);
     fprintf(stderr, "%s","DONE\n");
}
