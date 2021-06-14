#!/bin/bash

timestamp=`date +%Y-%m-%d_%H-%M-%S%Z`

if [ ! -d "./logs" ]; then
  mkdir logs
fi

touch ./logs/backup_home_cliente-03.sh_${timestamp}.log
logfile="./logs/backup_home_cliente-03.sh_${timestamp}.log"

echo "Archivo de log creado con exito" >> $logfile

if ping -c 1 -W 1 192.168.20.3; then
  echo "El cliente 03 esta en linea" >> $logfile
  echo "Copiando archivos del home remoto al disco de backups" >> $logfile

  rsync -avzrh -stats -e ssh --delete --no-perms --exclude '.cache' user-cliente-03@192.168.20.3:/home /media/disco_backups/ --log-file=$logfile

  echo "***********************" >> $logfile
  echo "Backup finalizado" >> $logfile
  ls -la /media/disco_backups/home/user-cliente-03/ >> $logfile
else
 echo "El cliente 03 esta fuera de servicio" >> $logfile
fi
