# Repository Index

This repository contains scripts and documentation related to various tasks. Below is an index of the major files and their recent updates:

## Documentation

- **[Fixed Ingress](fixedingress.md)**
  - Description: This manual provides a step-by-step guide on how to enable SSL with TCP on Avi using Kubernetes configurations.

  
- **[Helm AKO](helm-ako.md)**
  - Description: This guide provides instructions to set up the helm version of AKO (Avi Kubernetes Operator) on a workload cluster in TKG-M (Tanzu Kubernetes Grid - Management) clusters. Typically, AKO is automatically installed based on an AKODeploymentConfig (ADC) in the management cluster. This guide offers step-by-step details with deviations from the default setup highlighted.


- **[Reroll](reroll.md)**
  - Description: When managing a Tanzu Kubernetes Grid (TKG) cluster integrated with Avi Networks' ADC, you might need to rebuild nodes, be it control planes or worker nodes, from scratch. Leveraging the Cluster API's clusterctl, you can initiate this by using the commands clusterctl alpha rollout restart kubeadmcontrolplane/<control-plane-name> for the control plane and clusterctl alpha rollout restart machinedeployment/<machine-deployment-name> for worker nodes. After executing, it's vital to verify the successful rebuild of nodes and ensure they adopt the updated configurations, especially if changes involve Avi ADC or the removal of components like AKO.

  
- **[TCP SSL](tcpssl.md)**
  - Description: Configuration and setup guide for TCP SSL.


## Scripts

- **[Make PDF from MD (makepdffrommc.sh)](makepdffrommc.sh)**
  - Description: A script to convert markdown data into PDF format in the current directory.

