# Firewall

Para configurar las interfaces de red como se pide en el TP modifique el archivo que se encuentra en la ruta **/etc/network/interfaces** para que quede de al siguiente manera.

    #Sale a internet
    auto enp0s3
    iface enp0s3 inet dhcp
    #Red 10
    auto enp0s8
    iface enp0s8 inet static
    address 192.168.10.1
    netmask 255.255.255.0
    #Red 20
    auto enp0s9
    iface enp0s9 inet static
    address 192.168.20.1
    netmask 255.255.255.0
    
## El firewall debera cargar la configuracion dde iptables al inicio
Modifico el archivo que se encuentra en la ruta **/etc/network/if-pre-up-d/iptables** para que quede de la siguiente manera.

    #!/bin/bash
    /sbin/iptables-restore < /etc/network/if-pre-up-d/iptables
    echo 1 > /proc/sys/net/ipv4/ip_forward
    
Luego de modificar este archivo debo hacerlo ejecutbale, esto lo hago con el siguiente comando.

    chmod +x /etc/network/if-pre-up-d/iptables
> Nota: La primer linea permite que se carguen las reglas al inicio y la segunda habilita el port forwarding.

## Las políticas por defecto de las 3 cadenas de la tabla FILTER sea DROP

    iptables -P INPUT -j DROP
    iptables -P OUTPUT -j DROP
    iptables -P FORWARD -j DROP
    
## El tráfico desde/hacia la interfaz loopback sea posible

    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT
> Nota_1: Tanto el -i como el -o hacen referencia al nombre de la interfaz en cuestion.
> Nota_2: Para guardar la configuracion de iptables en una rchivo lo hacemos con el coamndo iptables-save > /etc/nombre_archivo (/etc/iptables_rules).

## La única VM que puede administrar el firewall via ssh sea cliente-02

    iptables -A INPUT -p tcp -s 192.168.20.2 -i enp0s9 --dport 22 -m --state NEW,ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -p tcp --sport 22 -m --state ESTABLISHED -j ACCEPT
> Nota: El parámetro -p sirve para indicar el protocolo de comunicación, --dport hace referencia al puerto destino para el paquete, --sport hace referencia al puerto de salida para el paquete, -m activa el match para el parámetro que se pasa (state en este caso) y --state indica que solo acepte paquetes con los estados pasados como parámetro.

## La única VM que pueda navegar por internet sea cliente-03

    iptables -A FORWARD -s 192.168.20.3 -i enp0s9 -o enp0s3 -j ACCEPT
    iptables -A FORWARD -i enp0s3 -o enp0s9 -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
    
## La única VM de la red 192.168.20.0/24 que pueda ingresar al web server de la red 192.168.10.0/24 sea cliente-04

    iptables -A FORWARD -i enp0s8 -o enp0s9 -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A FORWARD -s 192.168.20.4 -i enp0s9 -o enp0s8 -j ACCEPT

# Web Server
Para trasnferir los archivos **jdk-8u202-linux-x64.tar.gz**, **apache-tomcat-8.5.54.tar.gz** y ** sample.war** a la VM use el programa **WinSCP**.
Luego descompirmi el archivo **jdk-8u202-linux-x64.tar.gz** con el siguiente comando.

    tar -xvf jdk-8u202-linux-x64.tar.gz -C /opt/
> Nota: El parámetro -x indica que queremos extraer el archivo, -f indica el archivo a descomprimir, -v muestra el progreso de descompresión (verbose) y -C inidca donde lo queremos descomprimir.

Para crear la variable de entorno JAVA_HOME en  **~/.bashrc** se agrega al final de dicho archivo lo siguiente.

    JAVA_HOME=/opt/jdk-1.8.0_202
    export PATH=$PATH:$JAVA_HOME/bin

Siguiendo con el archivo **apache-tomcat-8.5.54.tar.gz** para descomprimirlo hacemos lo siguiente.

    tar -xvf apache-tomcat-8.5.54.tar.gz.gz -C /opt/

Por último para configurar tomcat seguí la siguiente [guia](https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-9-on-debian-10).
Una vez hecho esto podremos ver en funcionamiento el servidor en **192.168.10.3:8080/abc123**.

# File Server
Primero cree la carpeta **disco_backups** en la ruta **/media**, luego reralice la configuracion de la partición **/dev/sdb** para que sea LVM. Esto lo hice siguiendo de la siguiente manera.

    fdisk /dev/sdb
    #Opción n + enter
    #Opción p + enter
    #Opción 1 + enter
    #Enter
    #+5G + enter
    #Opción t + enter + 8e (Linux LVM) + enter
    #Opción w + enter

## LVM
Una vez hecho esto procedo a instalar lvm2.

    apt install lvm2

Luego configuro con lvm el physical volume, volume group y el logical volume de la siguiente manera.

    pvcreate /dev/sdb1
    vgcreate vg_backup /dev/sdb1
    lvcreate -L 1G -n lv_backup vg_backup

Despues le doy formato la volumen lógico recientemente creado de la siguiente manera.

    mkfs.ext4 /dev/sdb1/vg_backup/lv_backup

Como anteúltimo paso veo cual es el UUID de la particion para poder configuar el archivo **fstab** y que se monte al iniciar la VM.

    blkid

Como último paso configuro el archivo **fstab** que se encuentra en la ruta **/etc/fstab** para que quede de la siguiente manera.

    UUID=7193d77e-3303-4071-99ff-32f42e943630 /media/disco_backups ext4 defaults 0 0

### Comandos útiles LVM

 - **pvs** -->Sirve para ver los volúmenes físicos configurados.
 - **pvremove** --> Sirve para sacarle el formato lvm a una partición.
 - **vgs** --> Sirve para ver los grupos de volúmenes configurados.
 - **vgextend** --> Sirve para agregarle a dicho grupo una nueva particion, este grupo debe existir.
 - **vgreduce** --> Sirve para sacar una particion de dicho grupo.
 - **lvs** --> Sirve para ver los volúmenes lógicos configurados.
 - **lvextend** --> Sirve para agregarle espacio a un volumen logico. 

>Nota: Para aumentar el espacio de un LV se puede hacer en caliente, pero para reducirlo el LV debe estar desmontado o nos dara un error

## Configuara SSH
Para configuara SSH y que nos nos pida la copntraseña cada vez que nos queremos conectar el cliente-03 hacemos lo siguiente.

    ssh-keygen
    ssh-.copy-id user-cliente-03@192.168.20.3

Luego nos pide por unica vez la contraseña, la ingresamos y ya está todo hecho.

## Rsync y CronJob
Tuve que instalar rsync con el siguiente comando.
    apt-install rsync

Una vez cree el script y lo hice ejecutable con el comando.

    chmod +x backup_home_cliente-03.sh
    
Luego configure el cronjob con el comando.

    crontab -e

Al final del archivo agregue a siguiente linea.

    53 18 * * * /media/disco_backups/backup_home_cliente-03.sh

>Nota: Para ver los cronjobs configurados lo podemos hacer con el comando crontab -l.

# DHCP-Server
Para configurar el dhcp-server segui la suiguiente [guía](https://servidordebian.org/es/wheezy/intranet/dhcp/server).
Para la configuracion del archivo **/etc/default/isc-dhcp-server** solo debemos indicar la interfaz que entregara las ip, esto queda de la siguiente manera.

    INTERFACESv4="enp0s3"
    INTERFACESv6=""

Por otro lado para configurar el archivo **/etc/dhcp/dhcpd.conf** indicamos el rango de ip que entreagara el dhcp-server y tambien debemos indicar la direccion del router, en este caso el firewall, con la ip 192.168.20.1. El archivo nos quedara con las siguientes lineas agreagadas.

    subnet 192.168.20.0 netmask 255.255.255.0 {
	    range 192.168.20.101 192.168.20.110;
	    option routers 192.168.20.1;
    }

# Cliente-03
Para configurar la interfaz de red de esta VM para que tenga un ip estático lo hice modificando el archivo **/etc/netplan/01-network-manager-all.yaml** de la siguiente manera.

    network:
      version: 2
      renderer: networkd
      ethernets:
        enp0s3:
          dhcp4: no
          addresses:
            -192.168.20.3/24
          gateway4: 192.168.20.1
          nameservers:
            addresses: [8.8.8.8, 1.1.1.1]

