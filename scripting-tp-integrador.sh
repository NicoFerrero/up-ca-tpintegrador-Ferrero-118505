#! /bin/bash

function menu(){
  clear
  echo "1) Sucesion de Fibonacci"
  echo "2) Invertir un numero"
  echo "3) Evaluacion de palindromo"
  echo "4) Cantidad de lineas de archivo"
  echo "5) Ordenar listado de numeros"
  echo "6) Cantidad de archivos por tipo en directorio"
  echo "7) Salir"
}

function presioneEnter(){
  echo ""
  read -n 1 -r -s -p $"${reset}Presione enter para continuar..."
  menu
}

option=0
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
menu
while true; do
  read -p "Ingrese una opcion: " option
  case $option in
    1)  clear
        echo "****SERIE DE FIBONACCI****"
        number=0
        first_number=0
	second_number=1
        read -p "Ingrese un numero: " number
        echo -n "La serie de fibonacci es: "
        for (( i=0; i<number; i++  ))
	do
	  echo -n "${green}$first_number "
          fn=$(($first_number + $second_number))
	  first_number=$second_number
	  second_number=$fn
	done
        presioneEnter
    ;;
    2)  clear
        echo "****Invertir un numero****"
        read -p "Ingrese un numero para invertir: " number
        echo -n "El numero invertido es: ${green}"
        echo $number | rev
        presioneEnter
    ;;
    3)  clear
        echo "****Evaluacion de palindromo****"
        read -p "Ingrese la palabra a evaluar: " string
        if [[ $(rev <<< "$string") == "$string" ]]; then
          echo "La palabra ${green}$string es palindromo${reset}"
        else
          echo "La palabra ${red}$string no es palindromo${reset}"
        fi
        presioneEnter
    ;;
    4)  clear
        echo "****Cantidad de lineas de archivo****"
        read -p "Ingrese el path del archivo: " path
        ##if test -r $path; then
          ##echo "${red}$path no tiene permiso de lectura${reset}"
        if test -d $path; then
          echo "${red}$path es un directorio, no se pueden leer sus lineas${reset}"
        elif test -f $path; then
          echo -n "El archivo tiene ${green}"
          cat $path | wc -l | tr '\n' ' '
          echo -n "lineas${reset}"
        else
          echo "${red}El archivo $path no existe${reset}"
        fi
        presioneEnter
    ;;
    5)  #clear
        echo "****Ordenar listado de numeros****"
        read -p "Ingrese el primer numero: " num1
        read -p "Ingrese el segundo numero: " num2
        read -p "Ingrese e tercer numero: " num3
        read -p "Ingrese el cuarto numero: " num4
        read -p "Ingrese el quinto numero: " num5
        echo "Listado ordenado"
        echo -e "${green}$num1\n${green}$num2\n${green}$num3\n${green}$num4\n${green}$num5${reset}" | sort -n
        presioneEnter
    ;;
    6)  clear
        echo "****Cantidad de archivos en directorio por tipo****"
        read -p "Ingrese el path del directorio a analizar: " path
        if test -d $path; then
	  directorios=$(ls -l $path | egrep -c '^d')
          echo "Hay ${green}$directorios directorios${reset} en el directorio indicado"
          links=$(ls -l $path | egrep -c '^l')
	  echo "Hay ${green}$links links${reset} en el directorio indicado"
          archivos=$(ls -l $path | egrep -c '^-')
	  echo "Hay ${green}$archivos archivos${reset} en el directorio indicado"
	  bloque=$(ls -l $path | egrep -c '^b')
	  echo "Hay ${green}$bloque dispositivos de tipo bloque${reset} en el directorio indicado"
	  caracter=$(ls -l $path | egrep -c '^c')
	  echo "Hay ${green}$caracter dispositivos de tipo caracter${reset} en el dicrectorio indicado"
	  pipe=$(ls -l $path | egrep -c '^p')
	  echo "Hay ${green}$pipe archivos de tipo pipe${reset} en el directorio indicado"
  	  socket=$(ls -l $path | egrep -c '^s')
	  echo "Hay ${green}$socket archivos de tipo socket${reset} en el directorio indicado"
	elif test -f $path; then
	  echo "${red}No es un directorio${reset}"
	else
	  echo "${red}Path inexisente${reset}"
	fi
	presioneEnter
    ;;
    7)  echo "${green}Hasta luego $(whoami)!!${reset}"
        break;;
    *)  clear
        echo "${red}Ingreso una opcion incorrecta${reset}"
        sleep 2
        menu
    ;;
  esac
done
exit 0
