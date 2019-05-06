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
# define BASH_SCRIPT "/gek8s-node-stop.sh"

/** Print usage and exist reporting an error code */
void print_usage_and_exit(void)
{
     const char *help = "\nusage: gek8s-node-stop-launcher [p1=v1] [p2=v2] ... [pn=vn]\n\n"
                        "pi=vi are pair of property values\n\n";
     fprintf(stderr, "%s", help);
     exit(EXIT_FAILURE);
}

/** Check permissions and call the bootstrap script as root user */
int main(int argc, char *argv[])
{     
     // switch to the root user by setting UID to 0
     // This is needed to run the startup node an root
     fprintf(stderr, "%s", "\nChecking root privileges... ");
     if (setuid(0))
     {
          fprintf(stderr, "%s", " ERROR\n");
          perror("You need root privileges!\n");
          print_usage_and_exit();
     }
     fprintf(stderr, "%s", "OK");

     // build boostrap command
     char cmd[PATH_MAX];
     char *cmd_arguments[(argc-1)*2];     
     if (getcwd(cmd, sizeof(cmd)) != NULL)     
     {
          strcat(cmd, BASH_SCRIPT);          
          for (int i = 1; i < sizeof(cmd_arguments)/sizeof(char*); i++)
          {
               cmd_arguments[i]="-v";
               cmd_arguments[i+1]=argv[i];
          }
     }
     else
     {
          perror("Error getting the current working directory");
          print_usage_and_exit();
     }

     // Execute the bash script with root privileges
     if(execvp(cmd, cmd_arguments)==-1){
          perror("\nError during node boostrap");
          exit(EXIT_FAILURE);
     }
}
