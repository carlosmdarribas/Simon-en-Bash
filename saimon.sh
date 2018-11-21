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
ORANGE='\033[0;33m' 
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
MODE=0              # Flag que cambia el modo de juego.
                    # 0 -> Lista seguida | 1 -> Lista intermitente.

# Vector que almacenará los colores de la secuencia en GAME.
declare -a COLORS
declare -a STATICS_COLORS=('R' 'A' 'V' 'Z') # Colores que pueden aparecer como máximo en la secuencia.

ERROR=0 #0 = No errors
SALIR=false

###########################################################################################################################################################
###########################################################################################################################################################
#                                                     +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+                                                                 #
#                                                     |G|R|O|U|P| |I|N|F|O|R|M|A|T|I|O|N|                                                                 #
#                                                     +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+                                                                 #
#=========================================================================================================================================================#
#
# SHOW_ALLOWED_ARGUMENTS
#
# Mostramos en pantalla la información con respecto al uso del script.
#
function SHOW_ALLOWED_ARGUMENTS
{
    clear
    echo "Uso: ./saimon.sh [-g]"
    echo -e "\n\t -g: \t\t Muestra los integrantes del equipo desarrollador del script.\n"
}

#
# SHOW_GROUP_DATA
#
# Mostramos la información acerca de los autores.
#
function SHOW_GROUP_DATA
{
    echo ""
    echo "+----------------------------------------------------+"
    echo "|                   TRABAJO SSOO I                   |"
    echo -e "|"${RED}"                       Saimon                       "${NC}"|"
    echo "|                                                    |"
    echo "| - Autores: Carlos Martín de Arribas                |"
    echo "|            Gonzalo Martín González                 |"
    echo "|                                                    |"
    echo "| - Curso:   2º Ingeniería Informática USAL          |"
    echo "+----------------------------------------------------+"    
    echo "" 
}

###########################################################################################################################################################
###########################################################################################################################################################
#                                                     +-+-+-+-+ +-+ +-+-+-+-+                                                                             #
#                                                     |C|A|S|E| |1| |G|A|M|E|                                                                             #
#                                                     +-+-+-+-+ +-+ +-+-+-+-+                                                                             #
#=========================================================================================================================================================#

function GAME
{
    READ_PARAMETERS

    TIME_INIT=$(date +'%s')


    NUM_FALLOS=0        # Variable contador que posee el valor del número de fallos cometidos 
    NUM_MAX_FALLOS=0    # Número máximo de fallos permitidos por el jugador.
    NUM_ACIERTOS=20     # Número de aciertos necesarios para ganar.
    SUCCES=0            # Flag de valor 1 si el jugador ha llegado al NUM_ACIERTOS de aciertos.
    GAME_OVER=0         # Flag que valdrá 1 si el jugador comete NUM_MAX_FALLOS fallos, produciendo el game over.
    COLOR_NUM=0         # Variable que contiene el número total de colores.
    COLOR_INDEX=0       # Variable que contiene el índice del color actual.

    #Mostramos la información sobre los colores.
    COLOR_INFO 

    while [[ $GAME_OVER -eq 0 ]]; do
        # Cargamos NEXT_COLOR con un valor comprendido entre 0 y NUM_COLORS definido en el archivo de configuración.
        NEXT_COLOR=$(( RANDOM % NUM_COLORS ))

        # Cargamos el array de colores con uno de los colores del array estático.
        # Posteriormente aumentamos el índice en 1.
        COLORS[$COLOR_NUM]=${STATICS_COLORS[$NEXT_COLOR]}
        COLOR_NUM=$((COLOR_NUM+1))

        COLOR_INDEX=0
        if [[ $COLOR_NUM -ne  $((NUM_ACIERTOS+1)) ]]; then
            PRESENT_COLORS
        fi

        if [[ $MENU -eq 1 ]]; then
            clear 
        fi

        while [[ $GAME_OVER -eq 0 && $COLOR_INDEX -ne $COLOR_NUM && $SUCCES -eq 0 ]]; do
            
            if [[ $MENU -eq 2 ]]; then
                clear 
            fi
            if [[ $COLOR_INDEX -eq 0 || $MENU -eq 2 ]]; then
                echo ""
            fi

            if [[ $COLOR_NUM -eq  $((NUM_ACIERTOS+1)) ]]; then
                SUCCES=1
                TIME_FIN=$(date +'%s')
                WRITE_TO_LOG
                PRINT_WINNER 
                PRESS_TO_CONTINUE
                SHOW_GUI
            fi

            printf "\nIntroduzca el color de la posición "
            printf $((COLOR_INDEX+1))": "
            read COLOR
            COLOR=$(echo ${COLOR^^})

            if [[ $COLOR != ${COLORS[$COLOR_INDEX]} ]]; then
                if [[ $NUM_FALLOS -eq $NUM_MAX_FALLOS ]]; then
                    # En caso de que el jugador falle y no le queden intentos.
                    clear
                    PRINT_GAME_OVER
                    GAME_OVER=1
                    TIME_FIN=$(date +'%s')
                    WRITE_TO_LOG
                else
                    # En caso de que el jugador falle pero todavia le queden intentos.
                    NUM_FALLOS=$((NUM_FALLOS+1))
                    COLOR_INDEX=$((COLOR_INDEX-1))
                    echo -e ${RED}"\n\tHas fallado. Intentos restantes: "$((NUM_MAX_FALLOS-NUM_FALLOS+1))"."${NC}
                    sleep 2;

                    PRESENT_COLORS 

                    if [[ $MENU -eq 1 ]]; then
                        clear 
                    fi                
                fi
            fi
            COLOR_INDEX=$((COLOR_INDEX+1))
        done
    done
}



function PRESENT_COLORS
{
    clear
    echo ""
    for (( J = 0; J < $COLOR_NUM; J++ )); do
        SHOW_COLOR ${COLORS[$J]} 
        sleep $TIME_BETWEEN
        if [[ MODE -eq 1 ]]; then
            clear
            echo ""
        fi
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
           CHECK_ERROR;;
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

###########################################################################################################################################################
###########################################################################################################################################################
#                                                     +-+-+-+-+ +-+ +-+-+-+-+-+-+                                                                         #
#                                                     |C|A|S|E| |2| |C|O|N|F|I|G|                                                                         #
#                                                     +-+-+-+-+ +-+ +-+-+-+-+-+-+                                                                         #
#=========================================================================================================================================================#

function CONFIG_MENU
{

    # Se lee el archivo de parámetros actuales.
    READ_PARAMETERS

    # Se solicitan al usuario los nuevos valores.
    echo ""
    echo -e "+ Número de colores: "$NUM_COLORS
    echo -e "+ Tiempo entre muestras: "$TIME_BETWEEN
    echo -e "+ Ruta del fichero de log: "$STATS_FILE

    # Se muestra una línea en blanco y se pregunta si se desea modificar. 
    echo
    read -p "¿Desea editar el archivo de configuración? [Y/N]: "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        CREATE_CONFIG_FILE 1
    elif [[ $REPLY =~ ^[Nn]$ ]]; then
        echo ""
    else
        echo "\nOpcion incorrecta. Saliendo al menu principal"
        sleep 0.5
        echo -ne "."
        sleep 0.5
        echo -ne "."
        sleep 0.5
        echo -ne "."
    fi
    PRESS_TO_CONTINUE
    SHOW_GUI
}
#
# CREATE_CONFIG_FILE
#
# Recibe un parámetro, que puede valer 0 o 1.
# En el caso de que sea 0, indica que se desea crear el archivo, y se procederá normal.
# En el caso de recibir un 1, indica que se desea editar y mostrará los valores actuales al usuario.
function CREATE_CONFIG_FILE
{

    # Comprobamos el acceso al fichero de config.
    CORRECT=0
    if [[ $1 -eq 1 ]]; then
        until [[ $CORRECT -eq 1 ]]; do
            if ! [[ -f $CONFIG_FILE ]]; then
                echo -e "\n"${RED}"ERROR: "${NC}"Ruta o permisos inválidos al fichero de configuracion "$CONFIG_FILE
                PRESS_TO_CONTINUE
            elif  ! [[ -r $CONFIG_FILE ]] || ! [[ -w $CONFIG_FILE ]] &&  [[ -a $CONFIG_FILE ]]; then
                echo -e "\n"${RED}"ERROR: "${NC}"Acceso denegado al fichero de configuracion."
                PRESS_TO_CONTINUE
            else
                CORRECT=1
            fi
        done
    fi

    # Pedimos los valores de NUMCOLORES
    CORRECT=0
    until [[ $CORRECT -eq 1 ]]; do
        if [[ $1 -eq 1 ]]; then
            # Modo edicion. Mostramos el valor actual.
            echo -ne " \nIntroduzca el número de colores (entre 2 y 4)[ Valor actual =" ${BLUE} $NUM_COLORS ${NC}"]: " 
        else 
            printf "\nIntroduzca el número de colores (entre 2 y 4): "
        fi

        read READ_NUM_COLOURS

        if [[ $READ_NUM_COLOURS -gt 4 || $READ_NUM_COLOURS -lt 2 ]]; then
            clear
            echo -e "\n"${RED}"ERROR: "${NC}"El parámetro introducido es incorrecto."
        else
            NUM_COLORS=$READ_NUM_COLOURS
            CORRECT=1
        fi
    done

    # Pedimos los valores de ENTRETIEMPO
    CORRECT=0
    until [[ $CORRECT -eq 1 ]]; do
        if [[ $1 -eq 1 ]]; then
            # Modo edicion. Mostramos el valor actual.
            echo -ne "Introduzca el tiempo entre opciones (entre 1 y 4)[ Valor actual =" ${BLUE} $TIME_BETWEEN ${NC}"]: "
        else
            printf "Introduzca el tiempo entre opciones (entre 1 y 4): "
        fi
        read READ_TIME_BETWEEN

        if [[ $READ_TIME_BETWEEN -gt 4 || $READ_TIME_BETWEEN -lt 1 ]]; then
            clear
            echo -e "\n"${RED}"ERROR: "${NC}"El parámetro introducido es incorrecto."
        else
            TIME_BETWEEN=$READ_TIME_BETWEEN
            CORRECT=1
        fi
    done

    # Pedimos el nombre del fichero de log.
    CORRECT=0
    until [[ $CORRECT -eq 1 ]]; do

        read -e -p "Introduzca el nombre y ubicacion del fichero de log: " -i $(pwd)"/log.txt" READ_FILE_PATH
        touch $READ_FILE_PATH

        if ! [[ -f $READ_FILE_PATH ]]; then
            clear
            echo -e "\n"${RED}"ERROR: "${NC}"Ruta o permisos inválidos."
            PRESS_TO_CONTINUE
        elif  ! [[ -r $READ_FILE_PATH ]] || ! [[ -w $READ_FILE_PATH ]] &&  [[ -a $READ_FILE_PATH ]];  then
            clear
            echo -e "\n"${RED}"ERROR: "${NC}"Acceso denegado sobre el fichero."
            PRESS_TO_CONTINUE
        else
            CORRECT=1
            STATS_FILE=$READ_FILE_PATH
        fi
    done

    # Llegados a este punto los 3 parámetros serán correctos.
    # En este caso, escribimos al nuevo archivo.
    echo -e "NUMCOLORES="$NUM_COLORS"\nENTRETIEMPO="$TIME_BETWEEN"\nESTADISTICAS="$READ_FILE_PATH > $CONFIG_FILE
    if [[ $1 -eq 1 ]]; then
        echo -e "\nParámetros cambiados correctamente."
    elif [[ $1 -eq 0 ]]; then
        echo -e "\nArchivo"${BLUE} $CONFIG_FILE ${NC} "creado satisfactoriamente"
    fi
}


###########################################################################################################################################################
###########################################################################################################################################################
#                                                     +-+-+-+-+ +-+ +-+-+-+-+-+                                                                           #
#                                                     |C|A|S|E| |3| |S|T|A|T|S|                                                                           #
#                                                     +-+-+-+-+ +-+ +-+-+-+-+-+                                                                           #
#=========================================================================================================================================================#

function STATS
{

    READ_PARAMETERS

    if test -r $STATS_FILE # Comprobamos que el archivo STATS_FILE exista.
    then

        # Partida|Fecha|Hora|Numerocolores|Tiempo|Longitudsecuencia|SecuenciaColores

        GAMES=0
        NUM_PERCENT=0
        TOTAL_TIME=0
        TOTAL_LENGTH=0
        SHORTEST_TIME=1000
        LONGEST_TIME=0
        SHORTEST_COLORSEC=1000
        LONGEST_COLORSEC=0
        NUMCOLOR_SEC_LONGEST=0.0f

        TIME_AVERAGE=0
        LENGTH_AVERAGE=0

        declare -a LENGTHS
        declare -a TIMES
        declare -a SHORTEST_GAME
        declare -a LONGEST_GAME
        declare -a SHORTEST_COLORSEC_GAME
        declare -a LONGEST_COLORSEC_GAME

        declare -a COLOR_SEC_LONGEST
        declare -a PERCENTS=("0" "0" "0" "0") #(R,A,V,Z)
        declare -a FORMAT=("Partida: " "Fecha: " "Hora: " "Número de colores: " "Tiempo jugado (seg): " "Longitud de la secuencia: " "Secuencia de colores: ")
        
        while IFS='' read -r line || [[ -n "$line" ]]; do # Lee linea a linea el archivo de estadisticas "STATS_FILE"

            TIMES[$GAMES]=$(echo $line | cut -f 5 -d "|")
            LENGTHS[$GAMES]=$(echo $line | cut -f 6 -d "|")

            if [[ $SHORTEST_TIME -gt ${TIMES[$GAMES]} ]]; then
                for (( I = 0; I <= 6; I++ )); do
                    SHORTEST_GAME[$I]=$(echo $line | cut -f $((I+1)) -d "|")
                done
                SHORTEST_TIME=$(echo $line | cut -f 5 -d "|")                
            fi
            if [[ $LONGEST_TIME -lt ${TIMES[$GAMES]} ]]; then
                for (( I = 0; I <= 6; I++ )); do
                    LONGEST_GAME[$I]=$(echo $line | cut -f $((I+1)) -d "|")
                done
                LONGEST_TIME=$(echo $line | cut -f 5 -d "|")
            fi

            if [[ $SHORTEST_COLORSEC -gt ${LENGTHS[$GAMES]} ]]; then
                for (( I = 0; I <= 6; I++ )); do
                    SHORTEST_COLORSEC_GAME[$I]=$(echo $line | cut -f $((I+1)) -d "|")
                done
                SHORTEST_COLORSEC=$(echo $line | cut -f 6 -d "|")
            fi
            if [[ $LONGEST_COLORSEC -lt ${LENGTHS[$GAMES]} ]]; then
                for (( I = 0; I <= 6; I++ )); do
                    LONGEST_COLORSEC_GAME[$I]=$(echo $line | cut -f $((I+1)) -d "|")
                done
                NUMCOLOR_SEC_LONGEST=$(echo $line | cut -f 4 -d "|")
                LONGEST_COLORSEC=$(echo $line | cut -f 6 -d "|")
                COLOR_SEC_LONGEST=$(echo $line | cut -f 7 -d "|")
            fi

            GAMES=$((GAMES+1))

        done < $STATS_FILE

        for (( I = 0; I < $GAMES; I++ )); do
            TOTAL_TIME=$((TOTAL_TIME+(TIMES[$I])))
        done

        for (( I = 0; I < $GAMES; I++ )); do
            TOTAL_LENGTH=$((TOTAL_LENGTH+(LENGTHS[$I])))
        done

        TIME_AVERAGE=$((TOTAL_TIME/GAMES))
        LENGTH_AVERAGE=$((TOTAL_LENGTH/GAMES))

        for (( I = 1; I <= $LONGEST_COLORSEC; I++ )); do  
            KEY=$(echo $COLOR_SEC_LONGEST | cut -f $I -d "-")
                case $KEY in
                    "R")
                        PERCENTS[0]=$((${PERCENTS[0]}+1))
                    ;;
                    "A")
                        PERCENTS[1]=$((${PERCENTS[1]}+1))
                    ;;
                    "V")
                        PERCENTS[2]=$((${PERCENTS[2]}+1))
                    ;;
                    "Z")
                        PERCENTS[3]=$((${PERCENTS[3]}+1))
                    ;;
                    *)ERROR=7 CHECK_ERROR;;
                esac
            NUM_PERCENT=$((NUM_PERCENT+1)) 
        done

        for (( I = 0; I <= $NUMCOLOR_SEC_LONGEST; I++ )); do
            PERCENTS[$I]=$(((PERCENTS[$I]*100)/NUM_PERCENT))
        done

        PRESENT_STATS

    else
        ERROR=6
        CHECK_ERROR
        SHOW_GUI
    fi
}

function PRESENT_STATS
{
    clear
    echo ""
    echo -e ${RED}"\t\t    GENERALES\n"${NC}
    echo -e " Número total de partidas jugadas: "${ORANGE}$GAMES${NC}
    echo -e " Media de las longitudes de las secuencias de todas las partidas jugadas: "${ORANGE}$LENGTH_AVERAGE${NC}
    echo -e " Media de los tiempos de todas las partidas jugadas: "${ORANGE}$TIME_AVERAGE${NC}
    echo -e " Tiempo total invertido en todas las partidas: "${ORANGE}$TOTAL_TIME${NC}

    echo -e ${RED}"\n\t\tJUGADAS ESPECIALES\n"${NC}

    echo " Partida más corta: "
    for (( I = 0; I < 7; I++ )); do
        echo -ne "\t"${FORMAT[$I]}""
        echo -e ${ORANGE}${SHORTEST_GAME[$I]}${NC}
    done

    echo -e "\n Partida más larga: "
    for (( I = 0; I < 7; I++ )); do
        echo -ne "\t"${FORMAT[$I]}""
        echo -e ${ORANGE}${LONGEST_GAME[$I]}${NC}
    done

    echo -e "\n Partida con menor longitud de colores: "
    for (( I = 0; I < 7; I++ )); do
        echo -ne "\t"${FORMAT[$I]}""
        echo -e ${ORANGE}${SHORTEST_COLORSEC_GAME[$I]}${NC}
    done

    echo -e "\n Partida con mayor longitud de colores: "
    for (( I = 0; I < 7; I++ )); do
        echo -ne "\t"${FORMAT[$I]}""
        echo -e ${ORANGE}${LONGEST_COLORSEC_GAME[$I]}${NC}
    done

    echo -e "\n Porcentaje de los diferentes colores de la jugada de mayor longitud de colores: \n"
    echo -ne " + "${RED}"ROJO"${NC}": "${ORANGE}
    printf "%.2f" ${PERCENTS[0]}
    echo "%"
    echo -ne ${NC}" + "${YELLOW}"AMARILLO"${NC}": "${ORANGE}
    printf "%.2f" ${PERCENTS[1]}
    echo "%"
    echo -ne ${NC}" + "${GREEN}"VERDE"${NC}": "${ORANGE}
    printf "%.2f" ${PERCENTS[2]}
    echo "%"
    echo -ne ${NC}" + "${BLUE}"AZUL"${NC}": "${ORANGE}
    printf "%.2f%n" ${PERCENTS[3]}
    echo -e "%"${NC}

}
###########################################################################################################################################################
###########################################################################################################################################################
#                                                     +-+-+-+-+-+-+-+-+-+  +-+-+-+-+-+-+-+-+-+-+                                                          #
#                                                     |F|U|N|C|I|O|N|E|S|  |A|U|X|I|L|I|A|R|E|S|                                                          #
#                                                     +-+-+-+-+-+-+-+-+-+  +-+-+-+-+-+-+-+-+-+-+                                                          #
#=========================================================================================================================================================#
#
# TEST_ARGUMENTS
#
# Comprueba que los argumentos que se le han pasado son correctos:
#
# Argumentos para la función: $*, definidos en funcion principal.
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
                CHECK_ERROR
                SHOW_ALLOWED_ARGUMENTS # Mostramos la forma de uso del script.
            fi
        else
            SHOW_GUI; # Si no tiene ningún parámetro, o tiene más de los necesarios, se ejecuta el juego.
        fi
    else
        ERROR=1
        CHECK_ERROR
    fi
}
#
# READ_PARAMETERS
#
# Comprueba que el archivo de configuración exista y que posea los datos correctos.
#
function READ_PARAMETERS
{

    INCORRECT=0

    if test -r $CONFIG_FILE # Comprobamos que el archivo CONFIG_FILE exista.
    then
        while IFS='' read -r line || [[ -n "$line" ]]; do # Lee linea a linea el archivo de configuracion "CONFIG_FILE"

            KEY=$(echo $line | cut -f 1 -d "=")
            VALUE=$(echo $line | cut -f 2 -d "=")

            case $KEY in
                "NUMCOLORES" ) NUM_COLORS=$VALUE 
                if [[ $NUM_COLORS -gt 4 || $NUM_COLORS -lt 2 ]]; then
                    ERROR=8
                    INCORRECT=1
                fi
                ;;
                "ENTRETIEMPO" ) TIME_BETWEEN=$VALUE
                if [[ $TIME_BETWEEN -lt 1 || $TIME_BETWEEN -gt 4 ]]; then
                    ERROR=9
                    INCORRECT=1
                fi    
                ;;
                "ESTADISTICAS" ) STATS_FILE=$VALUE
                FILE_NAME=$(echo $STATS_FILE | rev | cut -f 1 -d "/" | rev)
                if ! [[ $STATS_FILE == $(pwd)"/"$FILE_NAME ]] ; then
                    ERROR=10
                    INCORRECT=1
                fi
                ;;
                *) ERROR=4 
                   CHECK_ERROR;;
            esac

        done < $CONFIG_FILE
    else
        ERROR=3
        CHECK_ERROR
        ASK_FOR_CONFIG_FILE_CREATION
    fi
    
    CHECK_ERROR

    if [[ $INCORRECT -eq 1 ]]; then
        ASK_FOR_CONFIG_FILE_CREATION 
    fi
}
#
# ASK_FOR_CONFIG_FILE_CREATION
#
# Pregunta al usuario si desea crear un nuevo archivo de configuración.
#
function ASK_FOR_CONFIG_FILE_CREATION
{
    until [[ $CREATION_FILE_OPTION =~ ^[Yy]$ ]]; do
        echo -ne "\n¿Desea crear el archivo de configuracion "$CONFIG_FILE"? (y/n):  "
        read CREATION_FILE_OPTION 
        if [[ $CREATION_FILE_OPTION =~ ^[Yy]$ ]]; then
                CREATE_CONFIG_FILE 0
                PRESS_TO_CONTINUE
                SHOW_GUI
        elif [[ $CREATION_FILE_OPTION =~ ^[Nn]$ ]]; then
            FINISH_PROGRAM
        else
            echo -e ${RED}"\n\tOpción incorrecta."${NC}
            sleep 1
            clear
        fi
    done
}
#
# WRITE_TO_LOG
#
# Escribimos en el log previamente definido ($STATS_FILE) los datos correspondientes.
#
function WRITE_TO_LOG
{
    # Partida|Fecha|Hora|Numerocolores|Tiempo|Longitudsecuencia|SecuenciaColores
    PID=$$
    DATE_AND_TIME=$(date +'%m-%d-%Y|%H:%M:%S')
    LONG_SEC=$((COLOR_NUM-1)) # Cambiar en produccion
    TIME_PLAYED=$((TIME_FIN-TIME_INIT)) #Implementar

    echo -ne $PID"|"$DATE_AND_TIME"|"$NUM_COLORS"|"$TIME_PLAYED"|"$LONG_SEC"|"  >> $STATS_FILE   
    
    for (( i = 0; i < COLOR_NUM-2; i++ )); do
        echo -ne ${COLORS[$i]}"-" >> $STATS_FILE
    done

    echo -e ${COLORS[$((COLOR_NUM-1))]} >> $STATS_FILE
}
#
# PRESS_TO_CONTINUE
#
# Pausa el programa hasta que el usuario introduce un valor por teclado.
#
function PRESS_TO_CONTINUE
{
    echo -e "\nPulse <INTRO> para continuar."
    read
    echo -e "\n"${NC}
}
#
# FINISH_PROGRAM
#
# Termina el programa.
#
function FINISH_PROGRAM
{

    TIME_TO_SLEEP=0.6
    echo -ne "\nSaliendo del programa"
    sleep $TIME_TO_SLEEP
    echo -n "."
    sleep $TIME_TO_SLEEP
    echo -n "."
    sleep $TIME_TO_SLEEP
    echo  "."
    exit
}
#
# CHECK_ERROR
#
# Compruba si la variable ERROR esta cargada con algún valor distinto de 0, lo que significa que ha habido un error.
#
function CHECK_ERROR
{
    if [[ $ERROR -ne 0 ]]; then # Si !0
        PRINT_ERROR $ERROR  #IMPLEMENTAR PRINT_ERROR
    fi
}
#
# PRINT_ERROR
#
# Imprime en pantalla un mensaje acerca del error que ha ocurrido.
#
function PRINT_ERROR
{

    clear
    echo -e ${RED}"\n\tERROR "$1": "${NC}

    case $ERROR in
        "1")
            echo -e ${BLUE}"\t(TEST_ARGUMENTS) "${NC}"Número incorrecto de argumentos.\n"
            SALIR=1
        ;;
        "2")
            echo -e ${BLUE}"\t(TEST_ARGUMENTS) "${NC}"El argumento es incorrecto.\n"
            sleep 2
            SALIR=1
        ;;
        "3")
            echo -e ${BLUE}"\t(READ_PARAMETERS) "${NC}"El archivo de configuracion no existe o no se puede leer.\n"
        ;;
        "4")
            echo -e ${BLUE}"\t(READ_PARAMETERS) "${NC}"Parametro de configuracion no encontrado.\n"
        ;;
        "5")
            echo -e ${BLUE}"\t(SHOW_COLOR) "${NC}"Color no especificado.\n"
            SALIR=1
        ;;        
        "6")
            echo -e ${BLUE}"\t(STATS) "${NC}"El archivo de log no existe o no se puede leer.\n"
            sleep 2
        ;;
        "7")
            echo -e ${BLUE}"\t(STATS) "${NC}"Color no especificado.\n"
            SALIR=1
        ;; 
        "8")
            echo -e ${BLUE}"\t(READ_PARAMETERS) "${NC}"El parámetro NUMCOLORES del archivo "$CONFIG_FILE" es incorrecto.\n"
        ;;
        "9")
            echo -e ${BLUE}"\t(READ_PARAMETERS) "${NC}"El parámetro ENTRETIEMPO del archivo "$CONFIG_FILE" es incorrecto.\n"
        ;;
        "10")
            echo -e ${BLUE}"\t(READ_PARAMETERS) "${NC}"El parámetro STATS_FILE del archivo "$CONFIG_FILE" es incorrecto o no se encuentra en el directorio del programa.\n"
        ;;
    esac
}

###########################################################################################################################################################
###########################################################################################################################################################
#                                                     +-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+                                                       #
#                                                     | IMPRESION | DE | MENSAJES | EN | PANTALLA |                                                       #
#                                                     +-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+                                                       #
#=========================================================================================================================================================#

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

function PRINT_WINNER
{
    echo -e "\n\n\n${GREEN}"
    echo -e "\t                           _   _     _   _   U _____ u   ____     "
    echo -e '\t __        __     ___     | \ |"|   | \ |"|  \| ___"|/U |  _"\ u  '
    echo -e '\t \"\      /"/    |_"_|   <|  \| |> <|  \| |>  |  _|"   \| |_) |/  '
    echo -e '\t /\ \ /\ / /\     | |    U| |\  |u U| |\  |u  | |___    |  _ <    '
    echo -e '\tU  \ V  V /  U  U/| |\u   |_| \_|   |_| \_|   |_____|   |_| \_\   '
    echo -e '\t.-,_\ /\ /_,-.-,_|___|_,-.||   \\,-.||   \\,-.<<   >>   //   \\_  '
    echo -e '\t \_)-'  '-(_/ \_)-' '-(_/ (_")  (_/ (_")  (_/(__) (__) (__)  (__) '
    echo -e "\n\n"
}

###########################################################################################################################################################
###########################################################################################################################################################
#                                                     +-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+                                                                 #
#                                                     |F|U|N|C|I|O|N| |P|R|I|N|C|I|P|A|L|                                                                 #
#                                                     +-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+                                                                 #
#=========================================================================================================================================================#

function SHOW_GUI
{
    until test $SALIR = true
    do
        clear

        DISPLAY_MENU
        printf "\nSeleccione una opción: "
        read OPTION
        OPTION=$(echo ${OPTION^^})

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
                FINISH_PROGRAM
                ;;
            *)
                echo -e ${RED}"\n Opción Incorrecta."${NC}
                PRESS_TO_CONTINUE
                ;;
        esac


        CHECK_ERROR ERROR
    done
}

# NUEVA FUNCION PRINCIPAL
TEST_ARGUMENTS $*
