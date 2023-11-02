# Antrea Egress and ExternalIPPool Configuration Manual

## Overview
This manual guides you through the setup of Antrea Egress and ExternalIPPool resources, which enable fine-grained control over egress traffic originating from Pods in a Kubernetes cluster.

## Prerequisites
- A Kubernetes cluster with Antrea as the CNI plugin.
- `kubectl` CLI tool configured to communicate with your Kubernetes cluster.
- Nodes in your cluster that can be designated as egress gateways.

## Configuration Steps

### Step 1: Label Nodes for Egress Traffic

1. **Identify Nodes for Egress**: Determine which nodes should act as egress gateways. It's recommended to use nodes with direct access to the external network.

2. **Label the Nodes**: Assign a label to each egress gateway node to identify it. Use `kubectl label` as follows:

    ```sh
    kubectl label nodes <node-name> network-role=egress-gateway
    ```
    
    Replace `<node-name>` with the actual name of your node.

3. **Verify Node Labels**: Ensure the label has been applied:

    ```sh
    kubectl get nodes --show-labels
    ```

### Step 2: Create an ExternalIPPool

1. **Define the IP Ranges**: Decide on the IP ranges to be used for egress traffic. Ensure these are routable on your network and ideally outside any DHCP range to avoid conflicts.

2. **Create the ExternalIPPool Resource**: Define an `ExternalIPPool` resource in a YAML file:

    ```yaml
    apiVersion: crd.antrea.io/v1alpha2
    kind: ExternalIPPool
    metadata:
      name: my-external-ip-pool
    spec:
      ipRanges:
        - start: <start-ip>
          end: <end-ip>
        - cidr: <cidr>
      nodeSelector:
        matchLabels:
          network-role: egress-gateway
    ```
    
    Replace `<start-ip>`, `<end-ip>`, and `<cidr>` with your designated IP ranges.

3. **Apply the ExternalIPPool**: Execute the following command to create the pool:

    ```sh
    kubectl apply -f <path-to-your-externalippool-yaml>
    ```

### Step 3: Configure Egress Resources

1. **Determine Workloads for Egress**: Identify the Pods that will use the egress IPs by their labels or namespaces.

2. **Define Egress Resource**: Create an `Egress` resource in a YAML file for each workload:

    ```yaml
    apiVersion: crd.antrea.io/v1alpha2
    kind: Egress
    metadata:
      name: egress-for-workload
    spec:
      appliedTo:
        namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: <namespace>
        podSelector:
          matchLabels:
            app: <app-label>
      externalIPPool: my-external-ip-pool
    ```
    
    Replace `<namespace>` and `<app-label>` with your workload's namespace and application label, respectively.

3. **Deploy the Egress Resource**: Apply your configuration:

    ```sh
    kubectl apply -f <path-to-your-egress-yaml>
    ```

### Step 4: Verification and Monitoring

1. **Check Egress IP Assignments**: Run the following command to list Egress resources and their assigned IPs:

    ```sh
    kubectl get egress
    ```

2. **Monitor Node Assignments**: Verify the egress IP is correctly assigned to an appropriate node.

3. **Observe Traffic**: Ensure that egress traffic is routed through the assigned IPs.

## Best Practices and Notes
- **IP Management**: Allocate IPs that are outside the DHCP scope to avoid potential IP conflicts.
- **High Availability**: Use an `ExternalIPPool` for automatic failover in case an egress node fails.
- **Network Policies**: Consider defining network policies that complement your egress traffic rules for enhanced security.
- **Documentation**: Keep a record of the egress IPs and which workloads they correspond to for troubleshooting and maintenance.

## Troubleshooting
- **Egress IP Not Working**: Ensure the IP is routable in your network and no firewall rules are blocking traffic. An ip range of your node network can typically be used.
- **Egress IP Conflicts**: Check for IP conflicts within the network, especially if IPs are within the DHCP range.
- **Node Label Issues**: Make sure that nodes are correctly labeled and the labels match the `nodeSelector` in the `ExternalIPPool`.


## Example

```yaml
apiVersion: crd.antrea.io/v1alpha2
kind: ExternalIPPool
metadata:
  name: my-external-ip-pool
spec:
  ipRanges:
    - start: 192.168.40.10
      end: 192.168.40.30
  nodeSelector:
    matchLabels:
      network-role: egress-gateway
---
apiVersion: crd.antrea.io/v1alpha2
kind: Egress
metadata:
  name: static-egress-for-echoserver
spec:
  appliedTo:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: default
    podSelector:
      matchLabels:
        app: echoserver  # Assuming 'app: echoserver' is the label on your echoserver pods
  egressIP: 192.168.40.10  # This should be an available IP you wish to use for egress SNAT
  externalIPPool: my-external-ip-pool  # The name of your ExternalIPPool resource
```

```bash
[root@CentOS7TestVM ~]# k get nodes
NAME                                  STATUS   ROLES           AGE   VERSION
consti1-control-plane-gr5q9           Ready    control-plane   3d    v1.26.5+vmware.2
consti1-md-0-55b97fbb4dxp6xdd-wcj4k   Ready    <none>          3d    v1.26.5+vmware.2
```


```bash
kubectl label nodes consti1-md-0-55b97fbb4dxp6xdd-wcj4k network-role=egress-gateway
```