## Cluster API Manual

### 1. Downloading and Installing `clusterctl`

To download the `clusterctl` tool for Linux, use the following command:

```bash
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.5.3/clusterctl-linux-amd64 -o clusterctl
```

Next, install `clusterctl` to your local binaries:

```bash
sudo install -o root -g root -m 0755 clusterctl /usr/local/bin/clusterctl
```

### 2. Check Kubeadm Control Planes

To view the state of your Kubeadm control planes:

```bash
kubectl get kubeadmcontrolplane -A
```

Sample output:

```bash
NAMESPACE    NAME                    CLUSTER    INITIALIZED   API SERVER AVAILABLE   REPLICAS   READY   UPDATED   UNAVAILABLE   AGE     VERSION
default      consti1-control-plane   consti1    true          true                   2          1       1         1             2d22h   v1.26.5+vmware.2
default      wld-control-plane       wld        true          true                   1          1       1         0             4d20h   v1.26.5+vmware.2
tkg-system   mgmt-avi-95kwk          mgmt-avi   true          true                   1          1       1                       4d21h   v1.26.5+vmware.2
```

### 3. Check Machine Deployments

To view detailed information about Machine Deployments:

```bash
kubectl get machinedeployments -A -o wide
```

Sample output:

```bash
NAMESPACE    NAME                  CLUSTER    DESIRED   REPLICAS   READY   UPDATED   UNAVAILABLE   PHASE     AGE     VERSION
default      consti1-md-0          consti1    1         1          1       1         0             Running   2d22h   v1.26.5+vmware.2
default      wld-md-0              wld        1         1          1       1         0             Running   4d20h   v1.26.5+vmware.2
tkg-system   mgmt-avi-md-0-9wnvj   mgmt-avi   1         1          1       1         0             Running   4d21h   v1.26.5+vmware.2
```

### 4. Triggering Rollouts

To trigger a rollout for a specific Kubeadm Control Plane:

```bash
clusterctl alpha rollout restart kubeadmcontrolplane/consti1-control-plane
```

And for a specific Machine Deployment:

```bash
clusterctl alpha rollout restart machinedeployment/consti1-md-0
```

### 5. Checking vSphere Machines

To check the vSphere machines associated with your cluster:

```bash
kubectl get vspheremachines.infrastructure.cluster.x-k8s.io  -A
```

This manual provides the basic commands to manage and troubleshoot your Cluster API resources. Ensure you have the necessary permissions to perform these operations in your cluster.