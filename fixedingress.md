# Enable SSL with TCP on Avi

This manual provides a step-by-step guide on how to enable SSL with TCP on Avi using Kubernetes configurations.

## Prerequisites

- Kubernetes cluster setup and running.
- Avi Controller and Avi Kubernetes Operator (AKO) installed.
- `kubectl` command-line tool installed.

## Steps

### 1. Create a Namespace for the Echo Server

To create an isolated environment, we will set up the echo server inside its own namespace.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: echoserver
```

Apply the namespace:

```bash
kubectl apply -f namespace.yaml
```

### 2. Deploy the Echo Server

Deploy an echo server, which is a simple application that echoes the HTTP requests it receives.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echoserver
  namespace: echoserver
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

Apply the deployment:

```bash
kubectl apply -f deployment.yaml
```

### 3. Expose the Echo Server

To make the echo server accessible, create a Kubernetes service of type `LoadBalancer`.

```yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    ako.vmware.com/l4rule: my-l4-rule
  name: echoserver
  namespace: echoserver
spec:
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  type: LoadBalancer
  selector:
    app: echoserver
```

Apply the service:

```bash
kubectl apply -f service.yaml
```

### 4. Set up SSL with TCP

Using AKO's L4Rule Custom Resource Definition (CRD), define rules for Layer 4 load balancing, which in this case includes enabling SSL for TCP.

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

Apply the L4Rule:

```bash
kubectl apply -f l4rule.yaml
```

### 5. Verification

1. Get the IP of the LoadBalancer:

    ```bash
    kubectl get svc echoserver -n echoserver
    ```

2. Test the echo server over HTTPS (since SSL is enabled):

    ```bash
    curl https://<LoadBalancer_IP>
    ```

3. You should receive a response echoing back the request details.

## Conclusion

By following the above steps, you have successfully deployed an echo server and enabled SSL with TCP using Avi on a Kubernetes cluster. Ensure that you have proper SSL/TLS certificates set up for production environments.