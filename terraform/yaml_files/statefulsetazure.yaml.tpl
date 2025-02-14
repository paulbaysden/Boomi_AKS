apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: molecule
  labels:
    app: molecule
spec:
  selector:
    matchLabels:
      app: molecule
  serviceName: "molecule-service"
  replicas: 3
  template:
    metadata:
      labels:
        app: molecule
    spec:
      terminationGracePeriodSeconds: 900
      securityContext:
        fsGroup: 1000
      volumes:
        - name: molecule-storage
          persistentVolumeClaim:
            claimName: azure-netapp-pvc  # Use the existing PVC name
      initContainers:
        - name: fix-mount-permissions
          image: alpine:3.14.0
          securityContext:
            runAsUser: 0
          volumeMounts:
            - name: molecule-storage
              mountPath: "/mnt/boomi"
          command:
            - sh
            - -c
            - chown -R 1000:1000 /mnt/boomi
      containers:
        - image: boomi/molecule:release  # Change image to boomi/cloud:release for Boomi Cloud
          imagePullPolicy: Always
          name: atom-node
          ports:
            - containerPort: 9090
              protocol: TCP
          resources:
            limits:
              cpu: "1000m"
              memory: "1024Mi"
            requests:
              cpu: "500m"
              memory: "768Mi"
          volumeMounts:
            - name: molecule-storage  # Must match the 'volumes' section name
              mountPath: /mnt/boomi  # Directory inside the container to mount the NFS volume
          readinessProbe:
            periodSeconds: 10
            initialDelaySeconds: 10
            httpGet:
              path: /_admin/readiness
              port: 9090
          livenessProbe:
            periodSeconds: 60
            httpGet:
              path: /_admin/liveness
              port: 9090
          env:
            - name: BOOMI_ATOMNAME
              value: "namegoeshere"  # This is the name of your molecule
            - name: ATOM_LOCALHOSTID
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: BOOMI_ACCOUNTID
              value: accountidnoquoteshere  # Your Boomi Account ID
            - name: INSTALL_TOKEN
              value: molecule-16c2a346-3942-4d8c-xxxxx-xxx  # Upload new token
            - name: ATOM_VMOPTIONS_OVERRIDES # pipe delimited
              value:
            - name: CONTAINER_PROPERTIES_OVERRIDES # pipe delimited
              value:
