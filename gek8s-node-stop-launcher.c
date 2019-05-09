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
#include <limits.h>

// node boostrap script
#define BASH_SCRIPT "/gek8s-node-stop.sh"

/** Print usage and exist reporting an error code */
void print_usage_and_exit(void)
{
     const char *const help = "\nusage: gek8s-node-stop-launcher [p1=v1] [p2=v2] ... [pn=vn]\n\n"
                        "pi=vi are pair of property values\n\n";
     fprintf(stderr, help);
     exit(EXIT_FAILURE);
}

/** Check permissions and call the bootstrap script as root user */
int main(int argc, char *argv[])
{
     // switch to the root user by setting UID to 0
     // This is needed to run the startup node an root
     fprintf(stderr, "\nChecking root privileges... ");
     if (setuid(0))
     {
          fprintf(stderr, " ERROR\n");
          perror("You need root privileges!\n");
          print_usage_and_exit();
     }
     fprintf(stderr, "OK\n");

     // build boostrap command
     char cmd[PATH_MAX];
     // no. of args for execvp.  We need an extra 2 args:
     // 1. name of command
     // 2. NULL pointer to terminate the array
     const int n_cmd_args = (argc-1)*2 + 2;
     char *cmd_arguments[n_cmd_args];
     cmd_arguments[n_cmd_args - 1] = NULL; // must be NULL-terminated for execvp

     if (getcwd(cmd, sizeof(cmd)) != NULL)
     {
          strcat(cmd, BASH_SCRIPT);
          cmd_arguments[0] = cmd;
          for (int i = 1; i < n_cmd_args - 1; i+=2)
          {
               cmd_arguments[i] = "-v";
               cmd_arguments[i+1] = argv[i];
          }
     }
     else
     {
          perror("Error getting the current working directory\n");
          print_usage_and_exit();
     }

     // Execute the bash script with root privileges
     if(execvp(cmd, cmd_arguments) == -1){
          perror("\nError during node boostrap\n");
          exit(EXIT_FAILURE);
     }
}
