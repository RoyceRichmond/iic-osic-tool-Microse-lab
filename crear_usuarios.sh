
#!/bin/bash

# Reemplaza 'ral298' con tu nombre de usuario existente
existing_user=$(whoami)

export MY_PDK_ROOT="$HOME/pdk"
export MY_PDK=sky130A
export MY_STDCELL=sky130_fd_sc_hd
carpetas=terminales

if ! getent group grupossh >/dev/null; then
    sudo addgroup grupossh
fi

echo "$MY_PDK_ROOT"
# Crear la carpeta "pancho" en el directorio del usuario existente si no existe
sudo -u "$existing_user" mkdir -p /home/"$existing_user"/"$carpetas"

# Establecer a 'ral298' como propietario de la carpeta "pancho"
sudo chown -R "$existing_user":"$existing_user" /home/"$existing_user"/"$carpetas"

# Establecer permisos para que los usuarios hijos puedan leer archivos de "pancho"
sudo chmod -R 755 /home/"$existing_user"/"$carpetas"

# Crear 20 nuevos usuarios y asignar contraseñas
for i in $(seq 1 1 2)
do
	
    new_user="terminal$i"
    password="password$i"  # Cambia 'password' por la contraseña deseada
    dat_new_user="/home/terminal$i"
    sudo adduser --ingroup grupossh "$new_user"
    
    #sudo adduser --disabled-password --ingroup grupossh "$new_user
    
    #sudo useradd -m "$new_user" -p "$password"

    #sudo usermod -a -G grupossh "$new_user"
    # Establecer permisos para que cada usuario solo pueda leer y escribir en su propia carpeta dentro de "pancho"
    sudo mkdir -p /home/"$existing_user"/"$carpetas"/"$new_user"
    sudo chown "$new_user":"$new_user" /home/"$existing_user"/"$carpetas"/"$new_user"
    sudo chmod 755 /home/"$existing_user"/"$carpetas"/"$new_user"

    sudo usermod -aG ssh "$new_user"
 
    if [ ! -d "$dat_new_user/.xschem" ]; then
	sudo mkdir "$dat_new_user/.xschem"
	
    fi
    sudo chmod 777 "$dat_new_user/.xschem"
    sudo cp -f "$HOME"/iic-init.sh /home/"$new_user"
    sudo chmod 755 /home/"$new_user"/iic-init.sh











    echo "Usuario $new_user creado correctamente con contraseña: $password"
done

echo "Proceso completado."

