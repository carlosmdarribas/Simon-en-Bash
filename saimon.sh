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

# Parámetros de configuración.
NUM_COLORS=0
STATS_FILE=""
TIME_BETWEEN=0

# Vector que almacenará los colores de la secuencia en GAME.
declare -a COLORS
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
            EXECUTE_GAME; # Si no tiene ningún parámetro, se ejecuta el juego.
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

function DISPLAY_MENU
{
    echo -ne "\033]11;#800000\007"

    GRAY='\e[95m'

    RED='\033[0;31m'  # DEBUG: Pasar a constantes
    GREEN='\033[0;32m'  # DEBUG: Pasar a constantes
    BLUE='\033[0;36m'  # DEBUG: Pasar a constantes
    YELLOW='\033[0;33m'  # DEBUG: Pasar a constantes
    NC='\033[0m' # No Color

    echo -e "\n${GRAY}"
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
    echo -e "\n"
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









