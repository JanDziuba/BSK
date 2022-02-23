#!/bin/bash
mkdir deposits
mkdir credits

sudo groupadd clients
sudo groupadd officers

setfacl -R -m group:clients:r-- credits deposits
setfacl -m group:clients:r-x credits deposits
setfacl -d -m group:clients:--- credits deposits

setfacl -R -m group:officers:rw- credits deposits
setfacl -m group:officers:rwx credits deposits
setfacl -d -m group:officers:rw- credits deposits

filename='uzytkownicy.txt'

while read userid role name sname
do
    if [[ "$userid" == "" ]]; then # empty line
        continue
    elif [[ "$role" == "officer" ]]; then
        sudo useradd -g officers -m $userid
    elif [[ "$role" == "client" ]]; then
        sudo useradd -g clients -m $userid
    else
        echo "role must be officer or client"; 
        exit 1
    fi

    echo -e "passwd\npasswd" | sudo passwd $userid
    sudo usermod -c "${name} ${sname}" $userid

done < $filename




