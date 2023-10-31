## **Setting Up the Helm Version of AKO on a Workload Cluster in TKG-M**

This guide provides instructions to set up the helm version of AKO (Avi Kubernetes Operator) on a workload cluster in TKG-M (Tanzu Kubernetes Grid - Management) clusters. Typically, AKO is automatically installed based on an AKODeploymentConfig (ADC) in the management cluster. This guide offers step-by-step details with deviations from the default setup highlighted.

### **Prerequisites**
- Access to the management cluster
- Knowledge of the workload cluster label you are working with

### **Procedure**

#### **1. Disable Auto AKO Install for All Clusters**

##### Change context to the management cluster
e.g. with kubectx

```bash
kubectx <mgmtcluster>
```

#### **2. Delete Existing AKODeploymentConfig**

Delete the existing `install-ako-for-all` AKODeploymentConfig.


```bash
kubectl get adc install-ako-for-all -o yaml > install-ako-for-all.bck.yaml
```

```bash
kubectl delete AKODeploymentConfig install-ako-for-all
```

#### **3. Recreate AKODeploymentConfig**

Here is the configuration to recreate the `install-ako-for-all` AKODeploymentConfig using labels.

```yaml
apiVersion: networking.tkg.tanzu.vmware.com/v1alpha1
kind: AKODeploymentConfig
metadata:
  name: install-ako-for-all
spec:
  adminCredentialRef:
    name: avi-controller-credentials
    namespace: tkg-system-networking
  certificateAuthorityRef:
    name: avi-controller-ca
    namespace: tkg-system-networking
  cloudName: Default-Cloud
  clusterSelector:
    matchLabels:
      install-avi: "true"
  controlPlaneNetwork:
    cidr: 192.168.50.0/24
    name: VLAN-50-PG
  controller: 192.168.10.50
  controllerVersion: 22.1.3
  dataNetwork:
    cidr: 192.168.50.0/24
    name: VLAN-50-PG
  extraConfigs:
    disableStaticRouteSync: false
    ingress:
      defaultIngressController: false
      disableIngressClass: true
      nodeNetworkList:
      - networkName: VLAN-40-PG
    l4Config:
      autoFQDN: default
  serviceEngineGroup: Default-Group
```

### Modifications:
```yaml
  clusterSelector:
    matchLabels:
      install-avi: "true"
```

Apply the above configuration:

```bash
kubectl apply -f <filename>.yaml
```

Replace `<filename>` with the name of the file containing the AKODeploymentConfig configuration.

To match the ADC with a label and set the label to existing clusters:

```bash
kubectl label cluster <cluster-name> install-avi: "true"
```

#### **4. Creation of a Second Cluster**

Note: After the above steps, a second cluster created won't have AKO installed by default.

---

## Install Helm AKO on new workload cluster

### Example values.yaml

```yaml
# Default values for ako.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
### FeatureGates is to enable or disable experimental features.
featureGates:
  GatewayAPI: false # Enables/disables processing of Kubernetes Gateway API CRDs.
replicaCount: 1
image:
  repository: projects.registry.vmware.com/ako/ako
  pullPolicy: IfNotPresent
  pullSecrets: [] # Setting this will add pull secrets to the statefulset for AKO. Required if using secure private container image registry for AKO image.
  #pullSecrets:
  # - name: regcred
GatewayAPI:
  image:
    repository: projects.registry.vmware.com/ako/ako-gateway-api
    pullPolicy: IfNotPresent
### This section outlines the generic AKO settings
AKOSettings:
  primaryInstance: true # test if other is primary. Defines AKO instance is primary or not. Value `true` indicates that AKO instance is primary. In a multiple AKO deployment in a cluster, only one AKO instance should be primary. Default value: true.
  enableEvents: 'true' # Enables/disables Event broadcasting via AKO 
  logLevel: WARN   # enum: INFO|DEBUG|WARN|ERROR
  fullSyncFrequency: '1800' # This frequency controls how often AKO polls the Avi controller to update itself with cloud configurations.
  apiServerPort: 8080 # Internal port for AKO's API server for the liveness probe of the AKO pod default=8080
  deleteConfig: 'false' # Has to be set to true in configmap if user wants to delete AKO created objects from AVI 
  disableStaticRouteSync: 'false' # If the POD networks are reachable from the Avi SE, set this knob to true.
  clusterName: wld   # A unique identifier for the kubernetes cluster, that helps distinguish the objects for this cluster in the avi controller. // MUST-EDIT
  cniPlugin: '' # Set the string if your CNI is calico or openshift or ovn-kubernetes. For Cilium CNI, set the string as cilium only when using Cluster Scope mode for IPAM and leave it empty if using Kubernetes Host Scope mode for IPAM. enum: calico|canal|flannel|openshift|antrea|ncp|ovn-kubernetes|cilium
  enableEVH: false # This enables the Enhanced Virtual Hosting Model in Avi Controller for the Virtual Services
  layer7Only: false # If this flag is switched on, then AKO will only do layer 7 loadbalancing.
  # NamespaceSelector contains label key and value used for namespacemigration
  # Same label has to be present on namespace/s which needs migration/sync to AKO
  namespaceSelector:
    labelKey: ''
    labelValue: ''
  servicesAPI: false # Flag that enables AKO in services API mode: https://kubernetes-sigs.github.io/service-apis/. Currently implemented only for L4. This flag uses the upstream GA APIs which are not backward compatible
                     # with the advancedL4 APIs which uses a fork and a version of v1alpha1pre1
  vipPerNamespace: 'false' # Enabling this flag would tell AKO to create Parent VS per Namespace in EVH mode
  istioEnabled: false # This flag needs to be enabled when AKO is be to brought up in an Istio environment
  # This is the list of system namespaces from which AKO will not listen any Kubernetes or Openshift object event.
  blockedNamespaceList: []
  # blockedNamespaceList:
  #   - kube-system
  #   - kube-public
  ipFamily: '' # This flag can take values V4 or V6 (default V4). This is for the backend pools to use ipv6 or ipv4. For frontside VS, use v6cidr
### This section outlines the network settings for virtualservices. 
NetworkSettings:
  ## This list of network and cidrs are used in pool placement network for vcenter cloud.
  ## Node Network details are not needed when in nodeport mode / static routes are disabled / non vcenter clouds.
  ## Either networkName or networkUUID should be specified.
  ## If duplicate networks are present for the network name, networkUUID should be used for appropriate network.
  nodeNetworkList: []
  # nodeNetworkList:
  #   - networkName: "network-name"
  #     networkUUID: "net-4567"
  #     cidrs:
  #       - 10.0.0.1/24
  #       - 11.0.0.1/24
  enableRHI: false # This is a cluster wide setting for BGP peering.
  nsxtT1LR: '' # T1 Logical Segment mapping for backend network. Only applies to NSX-T cloud.
  bgpPeerLabels: [] # Select BGP peers using bgpPeerLabels, for selective VsVip advertisement.
  # bgpPeerLabels:
  #   - peer1
  #   - peer2
  # Network information of the VIP network. Multiple networks allowed only for AWS Cloud.
  # Either networkName or networkUUID should be specified.
  # If duplicate networks are present for the network name, networkUUID should be used for appropriate network.
  vipNetworkList: 
    - networkName: VLAN-50-PG
      cidr: 192.168.50.0/24
  # vipNetworkList:
  #  - networkName: net1
  #    networkUUID: net-1234
  #    cidr: 100.1.1.0/24
  #    v6cidr: 2002::1234:abcd:ffff:c0a8:101/64 # Setting this will enable the VS networks to use ipv6 
### This section outlines all the knobs  used to control Layer 7 loadbalancing settings in AKO.
L7Settings:
  defaultIngController: 'true'
  noPGForSNI: false # Switching this knob to true, will get rid of poolgroups from SNI VSes. Do not use this flag, if you don't want http caching. This will be deprecated once the controller support caching on PGs.
  serviceType: NodePort # enum NodePort|ClusterIP|NodePortLocal
  shardVSSize: LARGE   # Use this to control the layer 7 VS numbers. This applies to both secure/insecure VSes but does not apply for passthrough. ENUMs: LARGE, MEDIUM, SMALL, DEDICATED
  passthroughShardSize: SMALL   # Control the passthrough virtualservice numbers using this ENUM. ENUMs: LARGE, MEDIUM, SMALL
  enableMCI: 'false' # Enabling this flag would tell AKO to start processing multi-cluster ingress objects.
### This section outlines all the knobs  used to control Layer 4 loadbalancing settings in AKO.
L4Settings:
  defaultDomain: '' # If multiple sub-domains are configured in the cloud, use this knob to set the default sub-domain to use for L4 VSes.
  autoFQDN: default   # ENUM: default(<svc>.<ns>.<subdomain>), flat (<svc>-<ns>.<subdomain>), "disabled" If the value is disabled then the FQDN generation is disabled.
### This section outlines settings on the Avi controller that affects AKO's functionality.
ControllerSettings:
  serviceEngineGroupName: Default-Group   # Name of the ServiceEngine Group.
  controllerVersion: '22.1.3' # The controller API version
  cloudName: Default-Cloud   # The configured cloud name on the Avi controller.
  controllerHost: '192.168.10.50' # IP address or Hostname of Avi Controller
  tenantName: admin   # Name of the tenant where all the AKO objects will be created in AVI.
nodePortSelector: # Only applicable if serviceType is NodePort
  key: ''
  value: ''
resources:
  limits:
    cpu: 350m
    memory: 400Mi
  requests:
    cpu: 200m
    memory: 300Mi
securityContext: {}
podSecurityContext: {}
rbac:
  # Creates the pod security policy if set to true
  pspEnable: false

avicredentials:
  username: 'admin'
  password: 'BJHB8kD_xnIqku3+'
  authtoken:
  certificateAuthorityData:

persistentVolumeClaim: ''
mountPath: /log
logFile: avi.log
akoGatewayLogFile: avi-gw.log
```
#### Change these fields

```yaml
appropriate network.
  vipNetworkList: 
    - networkName: VLAN-50-PG
      cidr: 192.168.50.0/24
```


```yaml
  serviceType: NodePort # enum NodePort|ClusterIP|NodePortLocal
```


```yaml
avicredentials:
  username: 'admin'
  password: 'BJHB8kD_xnIqku3+'
```

#### Install on new WorloadCluster (w/o ako to use helm version)

```bash
helm install --generate-name oci://projects.registry.vmware.com/ako/helm-charts/ako --version 1.11.1 -f values.yaml  --namespace=avi-system
```

#### Create new cluster with default (non-helm) ako

##### Modify your workloadcluster.yaml to include AVI_LABELS

```yaml
AVI_CONTROL_PLANE_HA_PROVIDER: "true"
AVI_LABELS: |
  install-avi: "true"
```

If you create a cluster with this yaml it will include the default ako (not the helm one)
