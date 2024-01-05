#!/bin/bash

#Procedimentos

echo "Escolha uma opção"

function menu(){
    echo "------------------"
    echo "[1] Install"
    echo "[2] File Bash"
    echo "[3] Links"
    echo "[4] "
    echo "[5] "
    echo "Escolha uma opção:"
    read option
    if [[ $option == 1 ]]; then
        ./script/install.sh
    elif [[ $option == 2 ]]; then
        cp ./files/conf/bash_alias ~/.bash_alias
        cp ./files/conf/bash_var ~/.bash_var
        cp ./files/conf/bashrc ~/.bashrc
        cp ./files/conf/profile ~/.profile
    elif [[ $option == 3 ]]; then
        cp ./files/link/gmail /usr/bin/gmail;chmod 755 /usr/bin/gmail
        cp ./files/link/class /usr/bin/class;chmod 755 /usr/bin/class
        cp ./files/link/whats /usr/bin/whats;chmod 755 /usr/bin/whats
        cp ./files/link/drive /usr/bin/drive;chmod 755 /usr/bin/drive
    fi
}

function main(){
    option=1
    while [[ option -gt 0 ]]; do
        menu
    done
}

main