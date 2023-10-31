# Repository Index

This repository contains scripts and documentation related to various tasks. Below is an index of the major files and their recent updates:

## Documentation

- **[Fixed Ingress](fixedingress.md)**
  - Description: This manual provides a step-by-step guide on how to enable SSL with TCP on Avi using Kubernetes configurations.

  
- **[Helm AKO](helm-ako.md)**
  - Description: This guide provides instructions to set up the helm version of AKO (Avi Kubernetes Operator) on a workload cluster in TKG-M (Tanzu Kubernetes Grid - Management) clusters. Typically, AKO is automatically installed based on an AKODeploymentConfig (ADC) in the management cluster. This guide offers step-by-step details with deviations from the default setup highlighted.


- **[Reroll](reroll.md)**
  - Description: To rebuild a TKG-managed (TKG-m) or TKG-standalone (TKG-s) cluster and ensure each node is re-imaged and collects new configurations from the management cluster, utilize the Cluster API's clusterctl tool. Initiate the process with clusterctl alpha rollout restart kubeadmcontrolplane/<control-plane-name> for the control plane and clusterctl alpha rollout restart machinedeployment/<machine-deployment-name> for worker nodes. After executing, the nodes will be rebuilt, pulling the latest configurations from the management cluster.

  
- **[TCP SSL](tcpssl.md)**
  - Description: This guide will walk you through the process of setting up a load balancer with SSL and TCP support using the L4Rule in AKO.


## Scripts

- **[Make PDF from MD (makepdffrommc.sh)](makepdffrommc.sh)**
  - Description: A script to convert markdown data into PDF format in the current directory.

