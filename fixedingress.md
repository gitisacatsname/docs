apiVersion: ako.vmware.com/v1alpha1
kind: AviInfraSetting
metadata:
  name: dedicated-ais
spec:
  l7Settings:
    shardSize: DEDICATED

---
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: dedicated-ic
spec:
  controller: ako.vmware.com/avi-lb
  parameters:
    apiGroup: ako.vmware.com
    kind: AviInfraSetting
    name: dedicated-ais

---
apiVersion: ako.vmware.com/v1alpha1
kind: HostRule
metadata:
  name: dedicated-hr
  namespace: default
spec:
  virtualhost:
    fqdn: nginx-dedicated.foo.bar
  tcpSettings:
    loadBalancerIP: 192.168.50.30
  listeners:
    - port: 80
    - port: 443
  enableSSL: true

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: dedicated-ing
  namespace: default
spec:
  ingressClassName: dedicated-ic
  rules:
    - host: "nginx-dedicated.foo.bar"
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: echoserver
                port:
                  number: 80
