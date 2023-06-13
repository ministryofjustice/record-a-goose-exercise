apiVersion: apps/v1
kind: Deployment
metadata:
  name: moj-prototype-${BRANCH}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prototype-${BRANCH}
  template:
    metadata:
      labels:
        app: prototype-${BRANCH}
    spec:
      containers:
      - name: prototype
        image: ${REGISTRY}/${REPOSITORY}:${IMAGE_TAG}
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: prototype-service-${BRANCH}
  labels:
    app: prototype-service-${BRANCH}
spec:
  ports:
  - port: 3000
    name: http
    targetPort: 3000
  selector:
    app: prototype-${BRANCH}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: prototype-ingress-${BRANCH}
  annotations:
    external-dns.alpha.kubernetes.io/set-identifier: prototype-ingress-${BRANCH}-${KUBE_NAMESPACE}-green
    external-dns.alpha.kubernetes.io/aws-weight: "100"
spec:
  ingressClassName: default
  tls:
  - hosts:
    - ${KUBE_NAMESPACE}.apps.live.cloud-platform.service.justice.gov.uk
  rules:
  - host: ${KUBE_NAMESPACE}.apps.live.cloud-platform.service.justice.gov.uk
    http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: prototype-service-${BRANCH}
            port:
              number: 3000
