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

all: clean build permissions

build:
	gcc gek8s-node-start-launcher.c -o gek8s-node-start-launcher
	gcc gek8s-node-stop-launcher.c -o gek8s-node-stop-launcher

permissions: build
	sudo chown root gek8s-node-start-launcher && sudo chmod u+s gek8s-node-start-launcher
	sudo chown root gek8s-node-stop-launcher && sudo chmod u+s gek8s-node-stop-launcher

clean:
	rm -f gek8s-node-start-launcher
	rm -f gek8s-node-stop-launcher