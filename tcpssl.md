# Load Balancer Implementation Guide with SSL and TCP using L4Rule in AKO

This guide will walk you through the process of setting up a load balancer with SSL and TCP support using the L4Rule in AKO.

## Prerequisites:

- AKO (Avi Kubernetes Operator) installed and running in your Kubernetes cluster.
- `kubectl` configured to communicate with your cluster.

## Steps:

### 1. Deploy the Rule for Load Balancing

Deploy the L4 rule that describes how traffic should be balanced. The rule includes backend properties, listener properties, and the essential setting to enable SSL.

```yaml
apiVersion: ako.vmware.com/v1alpha2
kind: L4Rule
metadata:
  name: my-l4-rule
spec:
  backendProperties:
  - port: 80
    protocol: TCP
    enabled: true
  listenerProperties:
  - port: 80
    protocol: TCP
    enableSsl: true
```

To deploy the rule, save the above YAML to a file, say `l4rule.yaml`, and apply it:

```bash
kubectl apply -f l4rule.yaml
```

### 2. Deploy a Webserver

For this example, we'll deploy an echo server that will respond to requests on TCP port 80. This deployment will ensure that there's a web application running to test our load balancer.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echoserver
  namespace: default
spec:
  replicas: 5
  selector:
    matchLabels:
      app: echoserver
  template:
    metadata:
      labels:
        app: echoserver
    spec:
      containers:
      - image: ealen/echo-server:latest
        imagePullPolicy: IfNotPresent
        name: echoserver
        ports:
        - containerPort: 80
        env:
        - name: PORT
          value: "80"
```

Deploy the echo server:

```bash
kubectl apply -f echoserver-deployment.yaml
```

### 3. Create a Load Balancer and Map the Rule

Now, you'll create a service of type `LoadBalancer` which uses the previously defined L4Rule.

```yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    ako.vmware.com/l4rule: my-l4-rule
  name: echoserver
  namespace: default
spec:
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  type: LoadBalancer
  selector:
    app: echoserver
```

Deploy the service:

```bash
kubectl apply -f echoserver-service.yaml
```

Once the service is deployed, AKO will recognize the annotation `ako.vmware.com/l4rule: my-l4-rule` and will apply the L4 rule `my-l4-rule` to the load balancer created for the `echoserver` service.

## Verification:

After deploying the above resources, you can verify that the load balancer is working correctly:

1. Check the service's external IP:
   
   ```bash
   kubectl get svc echoserver
   ```

2. Access the webserver using the external IP. Ensure you can access it over HTTPS since we enabled SSL.

---
ckorte@vmware.com