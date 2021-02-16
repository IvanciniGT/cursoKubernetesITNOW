Con que tienen que ver los contenedores?

 √√√√ Entorno AISLADO para la ejecución de procesos

>> √ Flexibilidad. Es cierto, pero no es la característica principal. 
>> √ Abstracción de la infra. Es cierto, pero no es la característica principal.
>> √ Portabilidad. Es cierto, pero no es la característica principal.

 x Automatización ???
 x Escalabilidad. No per se. ==> Kubernetes/Openshift
 x Alta disponibilidad. No per se. ==> Kubernetes/Openshift
 x Virtualización? Es algo asi como Virt. a nivel de SO.

Un contenedor es un entorno AISLADO para la ejecución de procesos
 - Un contenedor va a tener acceso a cierto recursos predefinidos dentro de la máquina.
    Recursos:
        - CPU, Memoria
        - Red ?
            - Realmente los procesos que se ejecutan tienen acceso limitado a la red del host?
                Los procesos que se ejecutan en un contenedor tienen acceso a una red
                independiente de la del host. Quién me provee de esa red? Docker, Kubernetes, OS, ...
        - Almacenamiento ?
            - Almacenamiento local: chroot: 
                Los procesos que se ejecutan en el contenedor, tienen un acceso al filesystem del
                host restringido.
                    /
                        ect/
                        bin/
                        opt/
                        tmp/
                        sbin/
                        var/
                            subcarpeta1/
                                        ect/
                                        bin/  <<<< shell
                                        opt/
                                        tmp/
                                        sbin/
                                        var/

                    chroot es que un determinado proceso, cuando pregunte por el "root" /,
                        se le dirija a una carpeta del host
                    
                    Un proceso que tengo corriendo bajo chroot:
                        /var/subcarpeta1  ~ /
                                                ect/
                                                bin/
                                                opt/
                                                tmp/
                                                sbin/
                                                var/
                                                
            - Esto es suficiente?
                En la práctica, cuando trabajamos normalmente con contenedores?
                Nos falta persistencia? No siempre, un contenedor tiene persistencia per se?
                    Qué entendemos por persistencia?
                        Si monto un proceso en un contenedor en una máquina y el contenedor cae, 
                        Se borran sus datos? NO 

                        Posteriormente podría arrancar de nuevo el contenedor y tendría ahí todos sus datos.
                        Incluso con el contenedor apagado, sigo teniendo los datos en el HDD.
                    - Que otros procesos pudieran acceder a esos datos?
                        Pueden otros procesos acceder a esos datos?
                            Depende, si ejecuto un proceso sin chroot, sin problema
                            Si ejecutor un proceso con chroot, no podrá
                        En este caso, esta forma de trabajar con el almacenamiento NO ES SUFICIENTE
                    - Si ejecuto un proceso en otro host (este en un contenedor o no?) 
                        no podría tener acceso a los datos. Esto lo resolvería?: 
                            Almacenamiento Compartido: NFS, CIFS, CLOUD, ...
                        Sólo con montar un NF tengo el problema resuelto si mis procesos se ejecutan 
                        dentro de un contenedor?
                            A priori no... por que mi proceso está en chroot y no tiene acceso a ese volumen/carpeta
                            Para resolver esto tendría que? Montar ese volumen dentro del FS del contenedor
                    - Que pasa si borro un contenedor?
                        - Se borra su FS... y pierdo los datos <<<< PERSISTENCIA
                            Para no perderlos que hago?
                                - Los datos los guardo realemnet donde?
                                    en el FS del contenedor? NO
                                    Los guardo en un sitio externo:
                                        - host
                                        - nfs
                                        - cloud
                                    Y para que el contenedor tenga acceso a ellos? 
                                        Montó un volumen dentro del FS del contenedor que apunte
                                        a la fuente real de los datos

                            Es habitual borrar un contenedor?
                                MUCHISIMO !!!! Nos pasamos el día borrando contenedores.
                                    - Actualización de software <- Borro contenedor y lo recreo
                                    - Alta disponibilidad. Si se cae un contenedor
                                    - Escalabilidad. Si ya no necesito un contenedor, por carga de trabajo.
                    Donde podemos tener esos almacenamientos externos al FS del contenedor?
                        - En el cloud
                        - En un NAS
                        - En el host en su FS
                        - En el host en su RAM ?¿?¿
                            Eficiencia
                            Compartir datos entre 2 contenedores.
                        


 - Ya que tengo un entorno aislado, si un proceso dentro de un contenedor 
    falla no afectará a otros procesos en ejecución dentro mi máquina


En un contenedor montamos un SO?
    NO, esto no se puede hacer.
    Puede tener solo parte de un SO:
        - Librerias, comandos básicos:
            - ls? Depende, si está montado el comando si... si no no.
            - shell: sh, bash, zsh, bsh, fish


La gracia de los contenedores es que los procesos que corren dentro están en comunicación con ?
    - El kernel de quién? del host

Redhat, Ubuntu, Debian, Fedora => Distribucación de SO. GNU/Linux
Linux no es un SO. Es el kernel de un SO.

Si yo quiero instalar programas dentro de un Linux, que forma cómoda/estandar tengo?
- Gestor de paquetes?
    - Debian: apt
        - Ubuntu: apt, apt-get
    - Redhat: rpm yum



Cómo ejecutamos un proceso dentro de un contenedor dentro de un Ordenador?
 - Quién se encarga de eso?
    Esto no lo hace el kernel... Si bien, el kernel me da utilidades para ello.
        Que Kernel es el que me ofrece utilidades para poder ejecutar procesos aislados?
            El kernel de Linux: De forma nativa SOLO LINUX PUEDE EJECUTAR CONTENEDORES?
                - Windows? Si, pero antes no de forma nativa... 
                    Hoy en día si? Y ESO? QUE DICES IVAN !!!!!
                        Por el subsistema Linux que tiene Windows 10 (versión 2)
                            Un kernel de linux corriendo dentro de un windows
                - MacOS? NO ni de coña... Docker for MAC -< Mete una maquina virtual Linux
                - Otro UNIX®? A priori no, solo si se montan las herramientas que a día de hoy
                    ya se incluyen de manera estándar en el kernel de Linux 
        Que 2 herramientas grandes tenemos hoy a nivel de Kernel de Linux para ejecutar procesos aislados:
            - cgroups <<< Google (que por ejemplo son la opción por defecto DOCKER)
            - systemd <<<< es la forma recomendada por Kubernetes!

        
    Quien se encarga de ejecutar un contenedor es un EJECUTOR DE CONTENEDORES!!!
        que usa a su vez las herramientas del kernel de linux. (cgroups, systemd...)
        >>> runc <<<< run Container  <<< PROGRAMA QUE EJECUTAR CONTENEDORES.
            Cada vez que ejecutais un contenedor, lanzais un proceso runc a nivel de SO host
    
    Quien se encarga de crear contenedores y gestionarlos en LINUX?
        Un gestor de contenedores <<<<
            containerd, crio
        Se encargan de: crear un contenedor desde una IMAGEN DE CONTENEDOR.
                        tener un repositorio local de imágenes de contenedor.
                        descargar imágenes de contenedor
                        borrar un contenedor
                        gestionar el arranque y parada de contenedores

    Tenemos otro tipo de aplicaciones que me ofrecen utilidades extendidas para trabajar con contenedores:
        - Docker: 
            - Un API para containerd. API???
                - Un conjunto de operaciones invocables de una determinada forma
                En el caso de Docker, como es el API?
                    - dockerd: Docker daemon (REST)
                    - docker (CLI) desde linea de comandos mandar peticiones al dockerd
            - Hacer login sobre repositorios de imágenes de contenedor
            - Crear imágenes de contenedor
        - Podman: Con ventajas sobre docker... En tre ellas la principal, que no tiene un
                  demonio siempre corriendo. Ligero.
        - docker-compose... es otro cli de dockerd
        - Kubernetes
            - Un API para la gestión de contenedores?
                 SI claro... kubelet <<<<
                    Un servicio que tengo que tener instalado, donde? 
                        En TODOS los nodos de un cluster de Kubernetes
                    Kubelet, hasta hace poco (2 meses), queria por debajo hablar con dockerd <<<
                        Hoy en día kubelet ya puede hablar directamente con? containerd, crio
                    Para que quiero docker? una capa más de comunicación? FUERA !!!!

            - Kubectl que es?
                El cli... el equivalente al comando docker

NOTICION DE DICIEMBRE DE 2020: 
    Kubernetes se deshace de DOCKER. YA NO QUIERE DOCKER, ni ofrece soporte para docker.


--------
Qué es un Dockerfile?
Fichero para definir una IMAGEN DE CONTENEDOR.



containerD ? Docker
runc ?       Docker

Docker en sus primeras versiones era un MONOLITO. Su código era una maraña, que hacia muchas cosas.
En un momento dado, deciden hacer su código más modular:
    Docker
        Dockerd
            containerd >>>> Donarlas a fundaciones para su gestión
                runc   >>>> Donarlas a fundaciones para su gestión
--------
Rentabilización de docker:
    - docker-ce
    - docker-ee  <<< NO LA USA NI EL TATO (mirantis)
    - Docker-swarm <<< pinchao en hueso? Kubernetes es mejor
    - docker hub... que es con lo que sobreviven?
        Repositorio de imágenes: Admite 2 formas de trabajo:
            - Gratuita, pero entonces las imágenes que subas se las puede descargar TODO EL MUNDO
            - De pago, donde controlas quien puede descargar las imágenes.
--------
Qué es kubernetes?
    - Orquestador de contenedores.
No es igual que docker?
No es igual que docker, aunque permite hacer lo mismo que docker... solo que hace más cosas.
A qué va orientado Kubernetes?
    Al trabajo en un cluster, donde se ejecuten los contenedores.
    Por qué un cluster es importante?
        - Alta disponibilidad   |  En un entorno de producción
        - Escalabilidad         |
Kubernetes va orientado a ejecutar Contenedores en Clusters de máquinas.
Docker swarm es una alternativa... pero con mucha menos funcionalidad.. no se usa.
Openshift? Una distribución de Kubernetes... es un kubernetes con más cosas aún.

Kubernetes es Opensource
Openshift es opensource? SI !!!! <<<< Redhat
Cuantas versiones hay de Openshift?
    - OS Container platform: Versión de pago de Redhat (OJO Que si es opensource)
    - Origin es la versión libre de uso de OSCP. Su proyecto upstream.
        Aquí puedo tener problemas de estabilidad. Está mantenido por la comunidad. No hay soporte
    - OS Cloud. Servicio de Redhat, también de pago.
---------
Funcionalidades/Características adicionales que ofrece Kubernetes?
    - Al trabajar en un cluster nos ofrece:
        - Escalabilidad 
        - Alta disponibilidad
Que diferencias importantes surgen cuando trabajamos con contenedores en un Cluster 
    respecto a trabajar en un a única máquina, como podemos hacer con docker???
    - Los datos... el almacenamiento... Si ahora los contenedores pueden "volar" (borrar/crear)
        entre maquinas independientes, para que los datos se mantengan necesito:
            ALMACENAMIENTOS EXTERNOS <<<< Kubernetes me permite utilizar un sinfín de ellos
    - Cuando ejecuto un proceso en un contenedor, con docker, quién tiene acceso a los servicios 
        que ofrece ese contenedor?
        Los procesos que tenga ejecutándose en el host? Solo? 
            A priori si, ya que el contenedor se conecta a una RED VIRTUAL que solo existe en el host.
            Para salvar esta situación, normalmente mapeamos un puerto de la red del host al puerto de 
            la red del contenedor.
        
        Qué problema tiene está solución al trabajar en un cluster?



Máquina A                   Máquina B
Proceso   >>>>>>>>>>        Redirección de puertos      >>>>>  Proceso (contenedor)

En un cluster?

Máquina A                   Máquina incognita? con IP variable en tiempo
Proceso   >>>>>>>>>>        Redirección de puertos      >>>>>  Proceso (contenedor)

En un cluster qué necesito delante?
    Proxy con una IP fija
        Y cuando yo llamo a esa IP, el proxy me redirect a el CONTENEDOR En la IP adecuada
        Quién se encarga de la gestión y actualización del proxy? Kubernetes en AUTO
        Balanceador? Cuando? Cuando por detrás haya varios procesos dando ese servicio
    
    Cómo se llama ese proxy en Kubernetes? SERVICIO
        Que me da un servicio?
            - Endpoint para acceder al puerto del contenedor?
                Desde donde puede invocar a ese endpoint?
                    Depende del servicio:
                        - De manera básica, desde dentro de la red virtual de kubernetes
                        - Opcionalmente puedo vincular ese puerto a una IP de Nodo <<< Esto me resuelve algo?
                                NO... y de hecho no lo usamos para nada.
            - Balanceo de carga en las peticiones al servicio (al puerto de una app)

    ¿ Qué pasa entonces si quiero acceder a un servicio desde fuera de la red de Kubernetes?
        Otro proxy. INGRES <<< NGINX <<<< Quién gestiona eso? Kubernetes AUTO


------------
Kubeproxy??? 
    Un programa que tengo montado en todos los nodos, que se encarga de gestiona la RED VIRTUAL
     que crea Kubernetes, que a diferencia de la de docker, no está solo en un host


------------------------
Qué hace el comando EXPOSE en el dockerfile?
    Expone el puerto del contenedor a la red interna de docker. RUINA !!!!!!!
    ES SIMPLEMENTE INFORMATIVO. NO HACE NADA DE NADA




------------------------
Objetos de Kubernetes:
- Pod:
    Conjunto de 1 o más contenedores
        - Que comparten IP, recursos, MAQUINA ANFITRIONA (HOST)
        - Que además PUEDEN compartir almacenamiento LOCAL de manera sencilla
        - Que se gestionan de forma conjunta
        - Que se escalan de la misma forma (simultanea)

Dos contenedores que no formen un pod, pueden compartir almacenamiento? Si, sin problema

En que escenarios me interesa asegurar que 2 contenedores deben ir de la mano? Es decir,
los voy a poner en un POD?
    x Si yo tengo un POC con NGINX y otro con MariaDB, 
      tengo garantía de que si uno no arranca el otro tampoco? NO
    x Yo puedo poner nginx y mariaDB juntos en el mismo POD, y entonces si tengo la garantía.
        Esta sería buena solución? NO, porque puedo no querer gestión conjunta... 
        Que pasa con el escalado? NO RUINA !!!!
    √ Contenedor iniciador (Volumenes - git) + Otro contenedor
    √ Monitorización
        Nginx ----> Log      (este fichero log, será grande? NO) ===> VOLUMEN RAM
                     ^
        Fluend/Filebeat/Logstash   ---------> ElasticSearch

- Deployment  <<<< ReplicaSet
    - Un deployment lleva asociado una PLANTILLA DE POD!
    - Va pensado para ESCALADO: REPLICAS DE PODs generadas en base a la PLANTILLA
- StatefullSet  <<<< ReplicaSet
    - Es como un deployment, pero...
    - que mantiene id pod (que me importa poco a priori)
        - que lleva un ordende ejecución (que me importa también poco)
        - que si un pod se reasigna (Se mueve=> borrado/creación) 
            se le monten los MISMOS VOLUMENES
- ReplicaSet: Es un objeto que va intentar asegurarse que en un momento dado vamos a tener el número de 
    replicas deseado en ejecución.




- MariaDB único => POD
- Cluster de NGINX para poner un sitio WEB => 
    1º Donde está el sitio WEB? (colección de archivos html, js, css...)
        - Puede estár dentro del contenedor? Esto es normal? Ya ves... sobre todo en OS
            source2Image  => Deployment
        - Si la página se saca por ejemplo de un NFS => Deployment... todos los contenedores (pods)
            trabajan con el MISMO VOLUMEN
        - Ficheros de log. Pa que? => DEPLOYMENT
- ElasticSearch: Cluster
    --> Guardamos índices de documentos JSON
    --> Esos indices donde residen al final? En ficheros (segmentos)
    --> Todos los nodos del cluster tienen todos los datos?? 
            NO, se van asignando a unos u otros nodos (MASTER)
    --> Qué pasa si un nodo se cae?
        En términos generales dentro de elasticsearch
            - Si tengo los datos replicados?, el master se encarga de pedir que se copien 
                los datos a otro nodo ===> 
                    En este esceraio que me interesaría? 
                        ==> DEPLOYMENT ¿? A priori suficiente... que problema tengo
                            Ponte a copiar 150 Gbs de datos por la red... RESULTADO: TODO PETADO
                                Caida en cascada del cluster
                        ==> STATEFULSET <<<<<= ESTA LA GUAY !!!

            - Si no tengo los datos replicados? Me quedo sin los datos
                ---> Dado que cuando configuro un elasticsearch, los datos siempre voy a guardarlos 
                    en un sistema de almacenamiento externo (generalmente con redundancia), si se cae un nodo
                    que me interesa? Levantarlo de nuevo, pero apuntando a los mismos datos.
                    --> StatefulSet

------------------------------------
Más tipos de objetos en Kubernetes:
- PV??
    - PersistentVolume? 
        Un espacio de almacenamiento EXTERNO (en la práctica) prereservado.
        Un volumen que montamos en un pod, pero tien vida de forma independiente al pod.

- PVC ---> Asociada al POD
    - Persistent Volume claim
        Pa que vale esto? Separar la responsabilidad del desarrollador 
        .de la del administrador del cluster



PV00001 => Una carpeta en un servidor NFS llamada /carpatDeIvan
Pod , oye, kubernetes!!! dame el PV00001, que me lo enchufe ;)
Podría decir esto un POD en kubernetes?
    NO. Por qué se ha montado así?

---------
Quién (ser humano) interactua con un Kubernetes?
    - Administrador del Kubernetes
    - Alguien más? Desarrollador => Enchufame esta aplicación allí en el cluster

Para que el desarrollador pueda hacer esas operaciones que necesita???
    PERMISOS y kubectl

¿Cuando el desarrollador sube su aplicación, y necesita un volumen persistente, que pide?
- Mi aplicación necesita 20Gbs de almacenamiento persistente.... 
    - Que vaya rapidito
    - Me da igual que vaya rapidito
Al desarrollador le importa un c.... si estña en un NFS, Cloud, Cabina fibre channel???
    NO LE IMPORTA NADA.
Debe conocer el desarrollador (que puede ser un externo) esos detalles? 
    NO, NI DE COÑA !!!!


¿Quién crea los volumenes en kubernetes?
    - El administrador. Es el que sabe donde, como, cuanto.


El desarrollador se Flipa!!!!
    Dame 18 Pbs !!!
        Que hago, se los doy? De que vas ? Pa que!
---------
Otra cosa de Kubernetes que no tiene docker es GESTION DE USUARIOS!
    - Permisos en Kubernetes
    - En Kubernetes la gestión de usuarios y asignación de permisos está basada en ROLES

Un nuevo tipo de objeto en Kubernetes... varios:
    - Usuario (personas "físicas", cuentas de servicio)
    - Cuenta de servicio es a todos los efectos como si fuera un usuario, pero la labor
        realmente está siendo ejecutada por un programa.
    - Rol: Agrupación de permisos
    - RBAC

----------------------
Seguís creando los PVs a mano?
    - Aprovisionadores de Volumenes Automatizados NFS.

----------------------
Namespace!!!
    Que es un namespace?
        División longitudinal del cluster
    Me permite tener entorno independientes dentro del cluster => Característica de Kubernetes  
        MultiTenant => Un sistema que con una UNICA instalación puede antender a MULTIPLES clientes

Cuando creo cualquier objeto en Kubernetes, siempre va dentro de un NAMESPACE
NAMESPACE en OPENSHIFT? Cómo se le llama a esto? Project

En kubernetes, cada comando que quiero ejecutar sobre el cluster
    - que lo hago a través de kubectl, siempre le tengo que pasar el namespace "-n nombre_NAMESPACE"

En openshift, cómo se llama el cliente? oc
    Puedo asignar el namespace actual, con el que estoy trabajando.

--------------------------
Cuando arranco un POD... y por ende sus contenedores, quizás esos contenedores
requieren de configuraciones: 
    - Variables de Entorno
    - Intectando ficheros de configuración (Volumenes)

¿Qué pasa si quiero utilizar un mismo despliegue: Pod, deployment, statefulset en varios entornos?
    - DESARROLLO, PRUEBAS, PRODUCCION, PRE
    - La configuración no se mantiene constante a nivel de entorno
Me interesa definir las propiedades de configuración, junto con la información de despliegue: NO
Me interesa separarlo:
    Son conjuntos de propiedades de configuración que puedo definir e inyectar en un POD/Deployment/Statefulset
        ConfigMaps
        Secrets    <   Igual que un configMap que se guarda encriptado.
    
    Cómo puedo inyectar un configMap o un Secret en un POD?
        - Variables de Entorno  <<<< que se cargue desde un configmap
        - Intectando ficheros de configuración (Volumenes)   <<<< que se cargue desde un configmap
-----------------------------------------------
Arquitectura de Kubernetes
    En todas las máquinas del cluster necesito tener instalado?
        kubelet: Recibe peticiones y las despacha
            (docker)
                containerd , crio
                    runc

kubectl que es el cliente, éste se comunica con Kubelet

Qué más necesito en un Kubernetes?
    Kubeproxy?          Gestionar la RED VIRTUAL DE KUBERNETES
                        Servidor de DNS
    ETCD:               Base de datos de Kubernetes
    Scheduler:          Es el que decide el nodo en el que se despliega un POD
    ControlManager:     
                        Monitorizar los nodos
                        Gestionar las replicaciones
                        Gestiona los endpoints de los servicios
                        Gestión de usuarios/permisos, autenficaciones/autenticaciones
                        
    -                   Almacenamiento
                        Puede haber muchos... para cada tipo de almacenamiento...
                        
    kube-api            Cerebro

    Donde están todos estos programas instalados?
        En todos los nodos? NO (salvo el kubeproxy)
            Solo en unos nodos que son los que van a tener el CONTROL DEL CLUSTER (Maestros)
    
    ¿Cómo instalo estos programas en los nodos donde tengan que ir?
        Como contenedores. Todos esos programas se ejecutan como contenedores.
                            Siendo gestionados por KUBELET

    Para crear todos esos contenedores y descargar sus imágenes, 
        tenemos una utilidad que se llama?  KUBEADM
    
    Todas esas piezas de software se montan como PODs, dentro del namespace: kube-system
                                                                            CONTROL PLANE
Monitorización:
    Control de lo que tengo ahora <<<
    No quiero solo lo que tengo ahora, sino ver cómo evoluciona
    
Dentro de los contenedores ejecutamos software:
    - Servicio: Software que se ejecuta en segundo plano de forma indefinida y 
                que atiende peticiones de clientes (otro software) (Comunicación: puerto, socket):
                httpd: Servidor de web apache, weblogic, BBDD: Pods, deployments
    - Demonio:  Software que se ejecuta en segundo plano de forma indefinida, pero que
                no que atiende peticiones de clientes. Él sabe que hacer sin que 
                nadie le diga nada: crond ---> Cuando le toca ejecuta algo
                DAEMON
    - Script:   Programa que se ejecuta y acaba: JOB
    
Software:
    - Aplicación: Requiere interactividad con un ser humano
