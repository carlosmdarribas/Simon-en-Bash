#!/bin/bash

#  saimon.sh
#  TrabajoSSOOI_I
#
#  Created by Carlos y Gonzalo on 31/10/18.
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

# Parámetros de configuración de GAME
MENU=1              # Flag que cambia la forma en que se realiza la introduccion de datos
                    # 1 -> Seguido. | 2 -> Limpiando la pantalla.
SALTO=1             # Flag que cambia la forma en que se colocan los colores.
                    # 0 -> Seguidos. |1 -> De 5 en 5. | 2 -> De 10 en 10.

# Vector que almacenará los colores de la secuencia en GAME.
declare -a COLORS
declare -a STATICS_COLORS=('R' 'A' 'V' 'Z') # Colores que pueden aparecer como máximo en la secuencia.

ERROR=0 #0 = No errors
SALIR=false

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
# Mostramos la información acerca de los autores.
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

    NUM_FALLOS=0        # Variable contador que posee el valor del número de fallos cometidos 
    NUM_MAX_FALLOS=1    # Número máximo - 1 de fallos permitidos por el jugador.
    NUM_ACIERTOS=19     # Número de aciertos necesarios para ganar (EL 0 es el primer acierto.)
    SUCCES=0            # Flag de valor 1 si el jugador ha llegado al NUM_ACIERTOS de aciertos.
    GAME_OVER=0         # Flag que valdrá 1 si el jugador comete NUM_MAX_FALLOS fallos, produciendo el game over.
    I=0                 # Variable que contiene el número total de colores.
    K=0                 # Variable que contiene el índice del color actual.

    #Mostramos la información sobre los colores.
    COLOR_INFO 

    while [[ $GAME_OVER -eq 0 ]]; do
        # Cargamos NEXT_COLOR con un valor comprendido entre 0 y NUM_COLORS definido en el archivo de configuración.
        NEXT_COLOR=$(( RANDOM % NUM_COLORS ))

        # Cargamos el array de colores con uno de los colores del array estático.
        # Posteriormente aumentamos el índice en 1.
        COLORS[$I]=${STATICS_COLORS[$NEXT_COLOR]}
        I=$((I+1))

        K=0

        PRESENT_COLORS 

        if [[ $MENU -eq 1 ]]; then
            clear 
        fi

        while [[ $GAME_OVER -eq 0 && $K -ne $I && $SUCCES -eq 0 ]]; do
            
            if [[ $MENU -eq 2 ]]; then
                clear 
            fi
            if [[ $K -eq 0 || $MENU -eq 2 ]]; then
                echo ""
            fi

            printf "\nIntroduzca el color de la posición "
            printf $((K+1))": "
            read COLOR

            if [[ $COLOR != ${COLORS[$K]} ]]; then
                if [[ $NUM_FALLOS -eq $NUM_MAX_FALLOS ]]; then
                    # En caso de que el jugador falle y no le queden intentos.
                    clear
                    PRINT_GAME_OVER
                    GAME_OVER=1
                else
                    # En caso de que el jugador falle pero todavia le queden intentos.
                    NUM_FALLOS=$((NUM_FALLOS+1))
                    K=$((K-1))
                    echo -e ${RED}"\n\tHas fallado. Intentos restantes: "$((NUM_MAX_FALLOS-NUM_FALLOS+1))"."${NC}
                    sleep 2;

                    PRESENT_COLORS 

                    if [[ $MENU -eq 1 ]]; then
                        clear 
                    fi                
                fi
                if [[ $K -eq  $((NUM_ACIERTOS-1)) ]]; then
                    SUCCES=1
                fi
            fi
            K=$((K+1))
            if [[ $SUCCES -eq 1 ]]; then
                WINNER $K # IMPLEMENT
            fi
        done
        # Tenemos en COLORS la secuencia que debe introducir el usuario.
    done
}

function PRESENT_COLORS
{

    clear
    echo ""
    for (( J = 0; J < $I; J++ )); do
        SHOW_COLOR ${COLORS[$J]} 
        sleep $TIME_BETWEEN
    done
}

function SHOW_COLOR
{
    if [[ $(($J%5)) -eq 0 && $J -ne 0 && $SALTO -eq 1 ]]; then
        echo -e "\n"
    fi
    if [[ $(($J%10)) -eq 0 && $(($J%5)) -ne 0 && $J -ne 0 && $SALTO -eq 2 ]]; then
        echo -e "\n"
    fi
    # Argumento que se le pasa: $1, que contiene el color
    case $1 in
        'R' ) echo -ne ${RED} "████" ${NC} ;;
        'V' ) echo -ne ${GREEN} "████" ${NC} ;;
        'A' ) echo -ne ${YELLOW} "████" ${NC} ;;
        'Z' ) echo -ne ${BLUE} "████" ${NC} ;;
        *) ERROR=5
        SALIR=1 ;;
    esac

}

function COLOR_INFO
{
    echo ""
    echo "+------------------------+"
    if [[ NUM_COLORS -eq 4 ]]; then
        echo -e "| ${BLUE}Azul     ███${NC} ---> Z    |"    
        echo "|                        |"
    fi
    echo -e "| ${RED}Rojo     ███${NC} ---> R    |"
    echo "|                        |"
    if [[ NUM_COLORS -ge 3 ]]; then
        echo -e "| ${GREEN}Verde    ███${NC} ---> V    |"
        echo "|                        |"
    fi
    echo -e "| ${YELLOW}Amarillo ███${NC} ---> A    |"
    echo "+------------------------+"

    PRESS_TO_CONTINUE
    clear
}

function FINISH_PROGRAM
{
    echo -ne "\nSaliendo del programa"
    sleep 1
    echo -n "."
    sleep 1
    echo -n "."
    sleep 1
    echo  "."
    exit
}


function READ_PARAMETERS
{

    INCORRECT=false

    if test -r $CONFIG_FILE # Comprobamos que el archivo CONFIG_FILE exista.
    then
        while IFS='' read -r line || [[ -n "$line" ]]; do # Lee linea a linea el archivo de configuracion "CONFIG_FILE"

            KEY=$(echo $line | cut -f 1 -d "=")
            VALUE=$(echo $line | cut -f 2 -d "=")

            case $KEY in
                "NUMCOLORES" ) NUM_COLORS=$VALUE 
                if [[ $NUM_COLORS -gt 4 || $NUM_COLORS -lt 2 ]]; then
                    echo -e "\n"${RED}"ERROR: "${NC}"El parámetro NUMCOLORES del archivo "$CONFIG_FILE" es incorrecto."
                    INCORRECT=true
                fi    
                ;;
                "ENTRETIEMPO" ) TIME_BETWEEN=$VALUE
                if [[ $TIME_BETWEEN -lt 1 || $TIME_BETWEEN -gt 4 ]]; then
                    echo -e "\n"${RED}"ERROR: "${NC}"El parámetro ENTRETIEMPO del archivo "$CONFIG_FILE" es incorrecto."
                    INCORRECT=true
                fi    
                ;;
                "[ruta]log.txt" ) STATS_FILE=$VALUE ;;
                *) ERROR=4 ;;
            esac

        done < $CONFIG_FILE
    else
        ERROR=3
        echo -ne "\nDesea crear el archivo de configuracion " $CONFIG_FILE"? (y/n)"
        read CREATION_FILE_OPTION 
    fi

    if  test $INCORRECT = true ; then
        until [[ $CREATION_FILE_OPTION = "y" || $CREATION_FILE_OPTION == "Y" ]]; do
                echo -ne "\nDesea crear de nuevo el archivo?(y/n): "
                read CREATION_FILE_OPTION 
            if [[ $CREATION_FILE_OPTION = "y" || $CREATION_FILE_OPTION == "Y" ]]; then
                FILE_CREATOR # IMPLEMENT
                FINISH_PROGRAM
            elif [[ $CREATION_FILE_OPTION = "n" || $CREATION_FILE_OPTION == "N" ]]; then
                FINISH_PROGRAM
            else
                echo -e ${RED}"\n\tOpción incorrecta."${NC}
                sleep 1
                clear
            fi
        done

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
    #echo -ne "\033]11;#800000\007"

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
        printf "\nSeleccione una opción: "
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
                echo -e ${RED}"\n Opción Incorrecta."${NC}
                PRESS_TO_CONTINUE
                ;;
        esac

        CHECK_ERROR ERROR
    done

