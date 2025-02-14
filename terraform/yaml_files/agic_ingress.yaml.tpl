apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
spec:
  rules:
    - host: // need to define still
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: molecule-service
                port:
                  number: 80
