function loguear(){
    log=0
    while [ $log = 0 -o $log = 1 ]; do	
        echo -n "Usuario: "; read usuario
        echo -n "Contraseña para $usuario: "; stty -echo;
        read contrasena; stty echo
        echo -e	
	    while IFS=: read user pass full home; do
		    if [ $usuario = $user ]; then
			    if [ $contrasena = $pass ]; then
				    if [ $(date +"%H") -lt 12 ]; then
					    echo -e "Buen día $usuario\n"
				    elif [ $(date +"%H") -lt 19 ]; then
					    echo -e "Buena tarde $usuario\n"
				    else
					    echo -e "Buena noche $usuario\n"
				    fi
				    log=2
			    else
				    echo -e "Lo siento, contraseña no valida\n"
				    log=1
			    fi
		    fi
	    done < /etc/passwords
	    if [ $log = 0 ]; then
		    echo -e "Lo siento, usuario no valido\n"
	    fi
    done	
}

function crearUsuarios(){
    echo -n "Nombre de usuario: "; read newUser
    echo -e
    echo -n "Contraseña: "; read newPass
    echo -e
    echo $newUser
    echo $newPass
    echo "$newUser:$newPass:/home/$newUser" >> /etc/passwords
    ejecutar="$(grep ${instruccion[0]} /etc/commands | cut -d":" -f1) ${parametros[@]}"
    if ! $ejecutar 2>/dev/null; then
	    echo "No se puede ejecutar la orden, revisa los parametros y/o modificadores"
    fi
}

#!/bin/bash
#Logueo
#log=0 indica usuario incorrecto, log=1 indica usuario valido y
#contraseña incorrecta, log=2 indica logueado
clear
echo -e "\t\t\t\tMyShell Beta\n"
now=$(date +"%T")
echo -e "\t\t\t\t\t\t\t\tHora : $now"
loguear

if [ $usuario = "root" ]; then
	prompt="#"
else
	prompt="$"
fi
#Comandos :3
while :
do
	i=0
	found=0
	parametros=()
	read -p "$usuario@localhost$prompt " -a instruccion
	for parametro in ${instruccion[@]}; do
		if [[ $parametro != -* ]]; then
			parametros[i]=$parametro
		fi
		let i=i+1
	done
	unset parametros[0]
	while IFS=: read comando_original comando_modificado contiene mod1 mod1_mio mod2 mod2_mio mod3 mod3_mio; do
		if [ ${instruccion[0]} = $comando_modificado ] ; then
			if [ ${instruccion[0]} = "agregarusuario" ]; then
				if [ $usuario = "root" ]; then
					crearUsuarios
				else
					echo "No tienes permisos suficientes para crear usuarios"
				fi
				found=1
				break
			fi
			found=1
			ejecutar="$(grep ${instruccion[0]} /etc/commands | cut -d":" -f1) ${parametros[@]}"
			if ! $ejecutar 2>/dev/null; then
				echo "No se puede ejecutar la orden, revisa los parametros y/o modificadores"
			fi
			break;
		fi
	done < /etc/commands
	if [ $found = 0 ]; then
		echo -e "${instruccion[0]}: comando no encontrado u.u'"
	fi
done
