# ge-k8s

A tool to easily join resources of a GridEngine-*like* system as new *worker* nodes of an existing Kubernetes cluster. 

As an example, to join the list of nodes `host1,host2` (which need to meet the software requirements described below) you can launch `ge-k8s` as follows:

```
./gek8s-pe-start.sh --hosts host1,host2 \
                    -v k8s_api_endpoint=172.30.10.101:6443 \
                    -v k8s_kubeadm_token="zv18vk.q30uidedqilsdklj" \
                    -v k8s_node_labels="transient-node" \
                    -v k8s_node_labels=transient-computational-node
```

To disjoin the list of nodes `host1,host2` you have to run the following command:

```
./gek8s-pe-stop.sh --hosts host1,host2
```


### Usage on Grid Engine
On a Grid Engine system, with a parallel environment configure to use `ge-k8s` (see *Configure PE* section), you can easily join a group of resources of that system to an existing k8s cluster by launching an "infinte sleep" job (bound to that parallel environment) that requests multiple nodes. 

As an example, **n** k8s workers can be launched with the following Bash shell command:

```
qsub -pe k8s $(( $n * $slots_per_node )) \
     -b y sleep infinity \
     -v k8s_api_endpoint=172.30.10.101:6443,\
        k8s_kubeadm_token="zv18vk.q30uidedqilsdklj",\
        k8s_node_labels="transient-node"
```

* `$n` is the number of nodes to join and `$slots_per_node` is the max number of slots available on each node. Specify `$(( $n * $slots_per_node ))` to have the exclusive use of all the `$n` nodes;
* `k8s_api_endpoint` is endpoint of the k8s master API server;
* `k8s_kubeadm_token` is the `kubeadm` token required during the joining process;
* `k8s_node_labels` is list of comma-separated labels to be assigned to the new nodes to join.

Both the two parameters, `k8s_api_endpoint` and `k8s_kubeadm_token` can be obtained from the k8s master by launching the command `kubeadm token create --print-join-command` (see [kubeadm token](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-token/) for more details).

The joined k8s worker(s) can be deallocated by deleting the job above with the appropriate GE command (i.e., `qdel`) using the `<JOB ID>` provided by the job allocation command, i.e.:

```
qdel <JOB_ID>
```


## Prerequisites

The following list shows the software you need to have on every node:

* **Docker**, i.e., a Docker version compatible with the Kubernetes version of the existing k8s *Control Plane*. It is required to have the corresponding service properly configured; 
* **Kubernetes**, i.e., the same Kubernetes available on the existing k8s *Control Plane*. `kubelet` needs to be configured as service;
* **`pdsh`**, i.e., *Parallel Distributed Shell*, used to issue commands to groups of hosts in parallel.

## Install and configure
* make `gs-k8s` code available on all the nodes to join
* configure a Grid Engine queue/pe (TBD)

<!-- ### Configure PE -->


<hr/>

Code released under the [Apache v2](https://raw.githubusercontent.com/crs4/ge-k8s/master/LICENSE) license. <br>
Copyright © 2019, [CRS4](http://www.crs4.it).
