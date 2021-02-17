sudo apt update
sudo apt -y install curl apt-transport-https
# Alta del repo y clave de Kubernete
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update

# Instalar Kubernetes y otros
sudo apt -y install vim git curl wget kubelet kubeadm kubectl

kubectl version --client && kubeadm version
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
sudo kubeadm config images pull
sudo vim /etc/hosts
ping micluster
sudo kubeadm init   --pod-network-cidr=192.168.0.0/16   --control-plane-endpoint=micluster
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl cluster-info
kubectl get pods --all-namespaces
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl get pods --all-namespaces


kubectl <comando> <sobre que tipo de objeto>  <argumentos si son necesarios>
          get
          rm 
          
kubectl apply -f nginx-deployment.yaml 

1º Deployment
2º ReplicaSet 3
3º Se crean los 3 pods basados en la plantila
     - Kube-scheduller <<< Determinar en que nodo se va a poner cada pod
         - Pod 1 -> nodo1
         - Pod 2 -> nodo
     - Kubelet del nodo X para el pod X
        - Quiero tener ahí un pod
            - Descargar si no la tiene la imagen
            - Crear el contenedor
            - Lo arranca

¿Donde se ha creado esto... el deployment?
    En el namespace default
    
kubectl taint nodes --all node-role.kubernetes.io/master-

Para que valen los servicios en kubernetes?
    √ Para descubrir el puerto en el que se ejecuta un proceso en un contenedor de un pod
        a través de un nombre, que se reuelva en automático
    √ Para balancear la carga entre pods
    
    X Para que tenga visibilidad el puerto del contenedor desde fuera del pod
    X Para poder acceder al puerto?

Tiene el pod una dirección IP? 
    SI √√√√√√√√√√√√√√√√√
    

Instalación del dashboard???
-----------------------------
Pods que tenemos corriendo en kubernetes

wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml