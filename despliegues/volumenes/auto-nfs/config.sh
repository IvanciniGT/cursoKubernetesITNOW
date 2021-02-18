# helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
# helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
#    --set nfs.server=172.31.14.20 \
#    --set nfs.path=/nfs/kubernetes

#### #### #### #### #### #### #### 
sudo tee -a peticion-volumen-2.yml > /dev/null <<EOT
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mi-peticion-volumen-nfs
spec:
    storageClassName: nfs-client
    resources: 
      requests:
        storage: 20Mi
    accessModes:
      - ReadWriteOnce
EOT

kubectl apply -f peticion-volumen-2.yml
