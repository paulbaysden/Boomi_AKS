apiVersion: v1
kind: PersistentVolume
metadata:
  name: azure-netapp-pv
spec:
  capacity:
    storage: 100Gi  # Adjust to your needs
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: azure-netapp-nfs
  nfs:
    server: "${netapp_server}"  # Terraform will replace this with the actual NetApp server IP
    path: "${netapp_path}"      # Terraform will replace this with the actual NetApp volume path
