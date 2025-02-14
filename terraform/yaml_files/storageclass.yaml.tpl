apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-netapp-nfs
provisioner: kubernetes.io/no-provisioner  # Indicates a static provisioning
volumeBindingMode: WaitForFirstConsumer
