apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azure-netapp-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azure-netapp-nfs
  resources:
    requests:
      storage: 100Gi  # Adjust to your needs
