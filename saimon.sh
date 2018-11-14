#!/bin/bash

#  saimon.sh
#  TrabajoSSOOI_I
#
#  Created by Güee Both on 31/10/18.
#

###########################################################################################################################################################
###########################################################################################################################################################
###########################################################################################################################################################
#                                                             +-+-+-+-+-+-+-+-+-+-+                                                                       #
#                                                             |C|O|N|S|T|A|N|T|E|S|                                                                       #
#                                                             +-+-+-+-+-+-+-+-+-+-+                                                                       #
#=========================================================================================================================================================#

# Ruta del fichero de configuración (en directorio actual)
CONFIG_FILE="confi.cfg"

# Colores y sus parámetros.
PURPLE='\e[95m'
RED='\033[0;31m'  # DEBUG: Pasar a constantes
GREEN='\033[0;32m'  # DEBUG: Pasar a constantes
BLUE='\033[0;36m'  # DEBUG: Pasar a constantes
YELLOW='\033[0;33m'  # DEBUG: Pasar a constantes
NC='\033[0m' # No Color

# Parámetros de configuración.
NUM_COLORS=0
STATS_FILE=""
TIME_BETWEEN=0

# Vector que almacenará los colores de la secuencia en GAME.
declare -a COLORS
declare -a STATICS_COLORS=('R' 'A' 'V' 'Z') # Colores que pueden aparecer como máximo en la secuencia.

#
# TEST_ARGUMENTS
#
# Comprueba que los argumentos que se le han pasado son correctos:
#
# Argumentos para la función: $1 $2, definidos en funcion principal
#
function TEST_ARGUMENTS
{
    if [[ $# -lt 2 ]]; then # Comprobamos que el numero de argumentos es menor que 2
        if [[ $# -eq 1 ]]; then # Comprobamos que el numero de argumentos es igual a 1. (Sin contar el nombre)
            if [[ $1 = "-g"  ]]; then # Comprobamos que el único argumento es "-g"
                SHOW_GROUP_DATA; # Mostramos la información del grupo desarrollador de este script.
                SALIR=true
            else
                ERROR=2
                ALLOWED_ARGUMENTS  #IMPLEMENT
            fi
        else
            EXECUTE_GAME; # Si no tiene ningún parámetro, o tiene más de los necesarios, se ejecuta el juego.
        fi
    else
        ERROR=1
    fi
}

#
# SHOW_GROUP_DATA
#
# Mostramos el nombre de los autores.
#
function SHOW_GROUP_DATA
{
    echo "Er Gonza y er Carlo han hesho eto" # DEBUG: Modificar en producción
}

#
# CHECK_ERROR
#
# Comprobamos si el flag "ERROR" es !0. (Si !0, error)
#
function CHECK_ERROR
{
    if [[ $ERROR -ne 0 ]]; then # Si !0
        PRINT_ERROR ERROR  #IMPLEMENTAR PRINT_ERROR
    fi
}

function CONFIG_MENU
{
    READ_PARAMETERS
}

function GAME
{
    READ_PARAMETERS


    FALLO=0
    I=0

    while [[ $FALLO -eq 0 ]]; do
        # Metemos
        NEXT_COLOR=$(( RANDOM % 4 ))

        COLORS[$I]=${STATICS_COLORS[$NEXT_COLOR]}
        I=$((I+1))

        for (( J = 0; J < $I; J++ )); do
            printf "_"${COLORS[$J]}" "
        done

        echo ""

        for (( J = 0; J < $I; J++ )); do
            SHOW_COLOR ${COLORS[$J]}
            sleep $TIME_BETWEEN
        done

        K=0
        while [[ $FALLO -eq 0 && $K -ne $I ]]; do
            clear
            printf "\n\nIntroduzca el color de la posición "
            printf $((K+1))": "
            read COLOR

            if [[ $COLOR != ${COLORS[$K]} ]]; then
                clear
                PRINT_GAME_OVER
                FALLO=1
            fi
            K=$((K+1))
        done
        # Tenemos en COLORS la secuencia que debe introducir el usuario.
    done
}

function SHOW_COLOR
{
    # Argumento que se le pasa: $1, que contiene el color
    case $1 in
        'R' ) echo -ne ${RED} "███"${NC} ;;
        'V' ) echo -ne ${GREEN} "███" ${NC} ;;
        'A' ) echo -ne ${YELLOW} "███" ${NC} ;;
        'Z' ) echo -ne ${BLUE} "███" ${NC} ;;
        *) ERROR=5
        SALIR=1 ;;
    esac
}


function READ_PARAMETERS
{

    if test -r $CONFIG_FILE # Comprobamos que el archivo CONFIG_FILE exista.
    then
        while IFS='' read -r line || [[ -n "$line" ]]; do # Lee linea a linea el archivo de configuracion "CONFIG_FILE"

            KEY=$(echo $line | cut -f 1 -d "=")
            VALUE=$(echo $line | cut -f 2 -d "=")

            case $KEY in
                "NUMCOLORES" ) NUM_COLORS=$VALUE ;;
                "ENTRETIEMPO" ) TIME_BETWEEN=$VALUE ;;
                "[ruta]log.txt" ) STATS_FILE=$VALUE ;;

                *) ERROR=4 ;;
            esac

        done < $CONFIG_FILE
    else
        ERROR=3
        echo "Desea crear el archivo de configuracion $CONFIG_FILE? (y/n)"
        # IMPLEMENTAR: Crear archivo y pedir argumentos al usuario.
    fi
}

function PRINT_GAME_OVER
{
    echo -e "\n\n\n${RED}"
    echo -e "\t\t  ▄████  ▄▄▄       ███▄ ▄███▓▓█████     ▒█████   ██▒   █▓▓█████  ██▀███  "
    echo -e "\t\t  ██▒ ▀█▒▒████▄    ▓██▒▀█▀ ██▒▓█   ▀    ▒██▒  ██▒▓██░   █▒▓█   ▀ ▓██ ▒ ██▒"
    echo -e "\t\t ▒██░▄▄▄░▒██  ▀█▄  ▓██    ▓██░▒███      ▒██░  ██▒ ▓██  █▒░▒███   ▓██ ░▄█ ▒"
    echo -e "\t\t ░▓█  ██▓░██▄▄▄▄██ ▒██    ▒██ ▒▓█  ▄    ▒██   ██░  ▒██ █░░▒▓█  ▄ ▒██▀▀█▄  "
    echo -e "\t\t░▒▓███▀▒ ▓█   ▓██▒▒██▒   ░██▒░▒████▒   ░ ████▓▒░   ▒▀█░  ░▒████▒░██▓ ▒██▒"
    echo -e "\t\t░▒   ▒  ▒▒   ▓▒█░░ ▒░   ░  ░░░ ▒░ ░   ░ ▒░▒░▒░    ░ ▐░  ░░ ▒░ ░░ ▒▓ ░▒▓░"
    echo -e "\t\t  ░   ░   ▒   ▒▒ ░░  ░      ░ ░ ░  ░     ░ ▒ ▒░    ░ ░░   ░ ░  ░  ░▒ ░ ▒░"
    echo -e "\t\t ░ ░   ░   ░   ▒   ░      ░      ░      ░ ░ ░ ▒       ░░     ░     ░░   ░ "
    echo -e "\t\t     ░       ░  ░       ░      ░  ░       ░ ░        ░     ░  ░   ░     "
}

function DISPLAY_MENU
{
    echo -ne "\033]11;#800000\007"

    echo -e "\n${PURPLE}"
    echo "███████╗ █████╗ ██╗███╗   ███╗ ██████╗ ███╗   ██╗"
    echo "██╔════╝██╔══██╗██║████╗ ████║██╔═══██╗████╗  ██║"
    echo "███████╗███████║██║██╔████╔██║██║   ██║██╔██╗ ██║"
    echo "╚════██║██╔══██║██║██║╚██╔╝██║██║   ██║██║╚██╗██║"
    echo "███████║██║  ██║██║██║ ╚═╝ ██║╚██████╔╝██║ ╚████║"
    echo "╚══════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝"
    echo -e "${NC}\n"

    echo -e "${RED}J) JUGAR"
    echo -e "${GREEN}C) CONFIGURACIÓN"
    echo -e "${BLUE}E) ESTADÍSTICAS"
    echo -e "${YELLOW}S) SALIR"
    echo -e "${NC}"

}

function PRESS_TO_CONTINUE
{
    echo -e "\nPulse <INTRO> para continuar."
    read
    echo -e "\n"${NC}
}
###########################################################################################################################################################
###########################################################################################################################################################
#                                                     +-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+                                                                 #
#                                                     |F|U|N|C|I|O|N| |P|R|I|N|C|I|P|A|L|                                                                 #
#                                                     +-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+                                                                 #
#=========================================================================================================================================================#

ERROR=0 #0 = No errors
SALIR=false

TEST_ARGUMENTS $*

CHECK_ERROR ERROR

until test $SALIR = true
    do
        clear

        # Testing zone
        #COMO FUNCIONA:
        # Añadir:     ARRAY[1]="caracla"
        # Imprimir: echo ${ARRAY[1]}
        # echo $(( RANDOM % 4 ))
        # echo ${STATICS_COLORS[0]}
        # +-----------------+
        # | ███ - ███ - ███ |
        # +-----------------+
        # Implementación de RANDOM
        # Cambios en GAME
        # Implemento de GAME_OVER
        #
        #

        DISPLAY_MENU
        printf "\nSeleccione una opcion: "
        read OPTION

        case $OPTION in
            "J")
                clear
                GAME
                PRESS_TO_CONTINUE
                ;;
            "C")
                clear
                CONFIG_MENU
                PRESS_TO_CONTINUE
                ;;
            "E")
                clear
                STATS
                PRESS_TO_CONTINUE
                ;;
            "S")
                SALIR=true
                ;;
            *)
                echo -e "\n Opción Incorrecta."
                PRESS_TO_CONTINUE
                ;;
        esac

        CHECK_ERROR ERROR
    done









