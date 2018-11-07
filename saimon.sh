#!/bin/bash

#  saimon.sh
#  TrabajoSSOOI_I
#
#  Created by Güee Both on 31/10/18.
#

function TEST_ARGUMENTS
{
    if [[ $# -lt 2 ]]; then
        if [[ $# -eq 1 ]]; then
            if [[ $1 = "-g"  ]]; then
                SHOW_GROUP_DATA;
                SALIR=true
            else
                ERROR=2
                ALLOWED_ARGUMENTS  #IMPLEMENT
            fi
        else
            EXECUTE_GAME;
        fi
    else
        ERROR=1
    fi
}

function SHOW_GROUP_DATA
{
    echo "Er Gonza y er Carlo han hesho eto" # DEBUG: Modificar en producción
}

function CHECK_ERROR
{
    if [[ $ERROR -ne 0 ]]; then
        PRINT_ERROR ERROR  #IMPLEMENTAR PRINT_ERROR
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

TEST_ARGUMENTS $1 $2

CHECK_ERROR ERROR

until test $SALIR = true
    do
        clear
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
    done









