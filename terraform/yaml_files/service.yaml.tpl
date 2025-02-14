apiVersion: v1
kind: Service
metadata:
  name: molecule-service
  namespace: default  # Specify the namespace if different
spec:
  selector:
    app: molecule  # Matches pods with label app: molecule
  ports:
    - protocol: TCP
      port: 80           # Port exposed by the service
      targetPort: 9090   # Port on the pod where the application is running
  type: ClusterIP  # Service type for internal cluster IP
