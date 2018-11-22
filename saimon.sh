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
ORANGE='\033[0;33m'  # Naranja
PURPLE='\e[95m'      # Morado
RED='\033[0;31m'     # Rojo
GREEN='\033[0;32m'   # Verde
BLUE='\033[0;36m'    # Azul
YELLOW='\033[0;33m'  # Amarillo
NC='\033[0m'         # No Color

# Parámetros de READ_PARAMETERS
INCORRECT=0         # Flag que pasa a valer 1 si encuentra algún error a la hora de leer los parámetros del archivo de configuración.

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

#
# Vectores estáticos.
#

# Colores que pueden aparecer como máximo en la secuencia.
declare -a STATICS_COLORS=('R' 'A' 'V' 'Z') 
# Formato en el que aparecen las jugadas especiales dentro de STATS
declare -a FORMAT=("Partida: " "Fecha: " "Hora: " "Número de colores: " "Tiempo jugado (seg): " "Longitud de la secuencia: " "Secuencia de colores: ") 

#
# Parámetros globales de control
#
ERROR=0         # Variable que nos indica el tipo de error. 0 => No hay errores.
SALIR=false     # Variable que controla la ejecución de SHOW_GUI.


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

#
# GAME
#
# Función principal del script. Permite al usuario jugar a Saimon.
#
function GAME
{
    # Leemos los parámetros procedentes del archivo de configuración.
    READ_PARAMETERS

    # Si se ha producido algún error en la lectura, se volverá al menu principal.
    if [[ INCORRECT -eq 1 ]]; then
        sleep 3
        SHOW_GUI
    fi

    # Inicio de una de las variables que nos permitirá medir el tiempo de juego.
    TIME_INIT=$SECONDS

    # Variables de GAME

    NUM_FALLOS=0        # Variable contador que posee el valor del número de fallos cometidos 
    NUM_MAX_FALLOS=0    # Número máximo de fallos permitidos por el jugador.
    NUM_ACIERTOS=20     # Número de aciertos necesarios para ganar.
    SUCCES=0            # Flag de valor 1 si el jugador ha llegado al NUM_ACIERTOS de aciertos.
    GAME_OVER=0         # Flag que valdrá 1 si el jugador comete NUM_MAX_FALLOS fallos, produciendo el game over.
    COLOR_NUM=0         # Variable que contiene el número total de colores.
    COLOR_INDEX=0       # Variable que contiene el índice del color actual.

    declare -a COLORS   # Vector que almacenará los colores de la secuencia.

    #Mostramos la información necesaria para jugar.
    COLOR_INFO 

    while [[ $GAME_OVER -eq 0 ]]; do
        # Cargamos NEXT_COLOR con un valor comprendido entre 0 y NUM_COLORS definido en el archivo de configuración.
        NEXT_COLOR=$(( RANDOM % NUM_COLORS ))

        # Cargamos el array de colores con uno de los colores del array estático.
        # Posteriormente aumentamos el índice en 1.
        COLORS[$COLOR_NUM]=${STATICS_COLORS[$NEXT_COLOR]}
        COLOR_NUM=$((COLOR_NUM+1))

        COLOR_INDEX=0
        # Si el jugador ha ganado, no se imprimirán los colores de la secuencia por pantalla.
        if [[ $COLOR_NUM -ne  $((NUM_ACIERTOS+1)) ]]; then
            PRESENT_COLORS
        fi

        if [[ $MENU -eq 1 ]]; then
            clear 
        fi

        # El bucle se ejecutará siempre que el jugador no haya ganado, perdido, o que el índice del color actual sea distinto que el número total de colores. 
        # (esto último sirve para que cuando el jugador haya terminado su secuencia de colores de manera correcta pero no sea la secuencia ganadora, salga del bucle,
        # listo para la siguiente secuencia)
        while [[ $GAME_OVER -eq 0 && $COLOR_INDEX -ne $COLOR_NUM && $SUCCES -eq 0 ]]; do
            
            if [[ $MENU -eq 2 ]]; then
                clear 
            fi
            if [[ $COLOR_INDEX -eq 0 || $MENU -eq 2 ]]; then
                echo ""
            fi

            # Si el número de colores de la secuencia actual coincide con el número de colores necesarios para ganar, el jugador ganará.
            if [[ $COLOR_NUM -eq  $((NUM_ACIERTOS+1)) ]]; then
                SUCCES=1
                TIME_FIN=$SECONDS
                WRITE_TO_LOG
                PRINT_WINNER 
                PRESS_TO_CONTINUE
                SHOW_GUI
            fi

            # Toma de los valores de la secuncia.
            printf "\nIntroduzca el color de la posición "
            printf $((COLOR_INDEX+1))": "
            read COLOR
            COLOR=$(echo ${COLOR^^})

            # Si el jugador falla. 
            if [[ $COLOR != ${COLORS[$COLOR_INDEX]} ]]; then
                # Si el numero de fallos cometidos es igual al número de fallos permitidos, el jugador perderá
                if [[ $NUM_FALLOS -eq $NUM_MAX_FALLOS ]]; then
                    clear
                    PRINT_GAME_OVER
                    GAME_OVER=1
                    TIME_FIN=$SECONDS
                    WRITE_TO_LOG
                # Si el jugador falla pero le quedan intentos, se mostrará por pantalla el número de intentos restantes y se imprimirá de nuevo la secuencia de colores.
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
#
# PRESENT_COLORS
#
# Presenta por pantalla la secuncia de colores de Saimon con un tiempo entre colores establecido en el archivo de configuración.
#
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
#
# SHOW_COLOR
#
# Función auxiliar de PRESENT_COLORS que muestra los colores mediante ████ de colores.
#
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
#
# COLOR_INFO
#
# Función que aporta la información necesaria al usuario para jugar a Saimon. 
# La información presentada depende del parámetro del número de colores del archivo de configuración.
#
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
#                                                     +-+-+-+-+ +-+   +-+-+-+-+-+-+                                                                         #
#                                                     |C|A|S|E| |2| | |C|O|N|F|I|G|                                                                         #
#                                                     +-+-+-+-+ +-+   +-+-+-+-+-+-+                                                                         #
#=========================================================================================================================================================#

#
# CONFIG_MENU
#
# Función que presenta por pantalla los parámetros del archivo de configuración y pregunta al usuario si desea editarlos.
#
function CONFIG_MENU
{
    # Se lee el archivo de parámetros actuales.
    READ_PARAMETERS

    # Se muestran al usuario los valores de las variables del archivo de configuración.
    echo ""
    echo -e "+ Número de colores: "${ORANGE}$NUM_COLORS${NC}
    echo -e "+ Tiempo entre muestras: "${ORANGE}$TIME_BETWEEN${NC}
    echo -e "+ Ruta del fichero de log: "${ORANGE}$STATS_FILE${NC}

    # Se muestra una línea en blanco y se pregunta si se desea modificar. 
    echo ""
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
    # Una vez terminado de editar el archivo, mostramos el menu principal.
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
    CORRECT=0 # Correct actúa a lo largo de la función como un flag para comprobar si la ejecución ha sido correcta.

    # Comprobamos el acceso al fichero de config.
    if [[ $1 -eq 1 ]]; then # Comparamos el valor del primer parámetro.
        until [[ $CORRECT -eq 1 ]]; do
            if ! [[ -f $CONFIG_FILE ]]; then # Comprobamos los permisos de acceso al fichero.
                echo -e "\n"${RED}"ERROR: "${NC}"Ruta o permisos inválidos al fichero de configuracion "$CONFIG_FILE
                PRESS_TO_CONTINUE
            elif  ! [[ -r $CONFIG_FILE ]] || ! [[ -w $CONFIG_FILE ]] &&  [[ -a $CONFIG_FILE ]]; then # Comprobamos si no se puede leer, escribir y editar.
                echo -e "\n"${RED}"ERROR: "${NC}"Acceso denegado al fichero de configuracion."
                PRESS_TO_CONTINUE
            else
                # Todas las condiciones se han cumplido. Proseguimos.
                CORRECT=1
            fi
        done
    fi

    # Pedimos los valores de NUMCOLORES
    CORRECT=0
    until [[ $CORRECT -eq 1 ]]; do
        if [[ $1 -eq 1 ]]; then
            # Modo edicion. Mostramos el valor actual.
            echo -ne " \nIntroduzca el número de colores (entre 2 y 4)[Valor actual ="${BLUE}$NUM_COLORS${NC}"]: " 
        else 
            # Modo creación. NO mostramos el valor actual, ya que no existe o no es relevante.
            printf "\nIntroduzca el número de colores (entre 2 y 4): "
        fi

        read READ_NUM_COLOURS

        # Comprobamos que el nuevo valor esté entre 2 y 4.
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
            echo -ne "Introduzca el tiempo entre opciones (entre 1 y 4)[Valor actual ="${BLUE}$TIME_BETWEEN${NC}"]: "
        else
            # Modo creación. NO mostramos el valor actual, ya que no existe o no es relevante.
            printf "Introduzca el tiempo entre opciones (entre 1 y 4): "
        fi

        read READ_TIME_BETWEEN

        # Comprobamos que el nuevo valor esté entre 1 y 4.
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

        # Comprobamos que la ruta existe y es un directorio.
        if ! [[ -f $READ_FILE_PATH ]]; then
            clear
            echo -e "\n"${RED}"ERROR: "${NC}"Ruta o permisos inválidos."
            PRESS_TO_CONTINUE
        # Comprobamos que se poseen los permisos necesarios para acceder al fichero.
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
        echo -e "\nArchivo" ${BLUE}$CONFIG_FILE${NC} "creado satisfactoriamente"
    fi
}


###########################################################################################################################################################
###########################################################################################################################################################
#                                                     +-+-+-+-+ +-+ +-+-+-+-+-+                                                                           #
#                                                     |C|A|S|E| |3| |S|T|A|T|S|                                                                           #
#                                                     +-+-+-+-+ +-+ +-+-+-+-+-+                                                                           #
#=========================================================================================================================================================#

#
# STATS
#
# Función que calcula las estadísticas a mostrar.
#
function STATS
{
    # Leemos los parámetros del archivo de configuración.
    READ_PARAMETERS

    if test -r $STATS_FILE ;then # Comprobamos que el archivo STATS_FILE exista.

        # Partida|Fecha|Hora|Numerocolores|Tiempo|Longitudsecuencia|SecuenciaColores

        # Variables de STATS

        GAMES=0                       # Variable que almacenará el número de partidas jugadas almacenadas en el archivo de log.
        NUM_PERCENT=0                 # Variable que almacenará el número de colores de la partida con la mayor secuencia de colores
                                      # para poder hallar los porcentajes de cada color.

        TOTAL_TIME=0                  # Variable que almacenará el tiempo total de juego. (Suma de los tiempos de todas las partidas del archivo de log)
        TOTAL_LENGTH=0                # Variable que almacenará la suma de todas las longitudes de las secuencias de colores de
                                      # las partidas almacenadas en el archivo de log.

        SHORTEST_TIME=1000            # Varible que ayudará a encontrar aquella partida con el menor tiempo de juego.
        LONGEST_TIME=0                # Varible que ayudará a encontrar aquella partida con el mayor tiempo de juego.
        SHORTEST_COLORSEC=1000        # Varible que ayudará a encontrar aquella partida con la menor secuencia de colores.
        LONGEST_COLORSEC=0            # Varible que ayudará a encontrar aquella partida con la mayor secuencia de colores.
        NUMCOLOR_SEC_LONGEST=0.0f     # Varible que almacenará el valor del número de colores de aquella partida con la secuancia de colores más larga.

        TIME_AVERAGE=0                # Variable que almacenará el valor promedio de todos los tiempos de las partidas del archivo de log.
        LENGTH_AVERAGE=0              # Variable que almacenará el valor promedio de todas las longitudes de las partidas del archivo de log.

        declare -a LENGTHS                # Vector que contendrá los valores de las longitudes de la secuencia de colores de cada
        declare -a TIMES                  # Vector que contendrá los valores de los tiempos de cada partida.
        declare -a SHORTEST_GAME          # Vector que contendrá la información relevante a aquella partida con menor duración.
        declare -a LONGEST_GAME           # Vector que contendrá la información relevante a aquella partida con mayor duración.
        declare -a SHORTEST_COLORSEC_GAME # Vector que contendrá la información relevante a aquella partida con la menor secuencia de colores.
        declare -a LONGEST_COLORSEC_GAME  # Vector que contendrá la información relevante a aquella partida con la mayor secuencia de colores.

        declare -a COLOR_SEC_LONGEST            # Vector que contendrá la secuencia de colores de la parida con la secuencia de colores más larga.
        declare -a PERCENTS=("0" "0" "0" "0")   # Vector que contendrá los porcentajes de cada color.(R A V Z).
        
        # Leemos linea a linea el archivo de estadisticas "STATS_FILE"
        while IFS='' read -r line || [[ -n "$line" ]]; do 

            TIMES[$GAMES]=$(echo $line | cut -f 5 -d "|")                               # Tomamos los tiempos de cada partida.
            LENGTHS[$GAMES]=$(echo $line | cut -f 6 -d "|")                             # Tomamos las longitudes de cada partida.

            if [[ $SHORTEST_TIME -ge ${TIMES[$GAMES]} ]]; then
                for (( I = 0; I <= 6; I++ )); do
                    SHORTEST_GAME[$I]=$(echo $line | cut -f $((I+1)) -d "|")            # Tomamos la información de la partida más corta.
                done
                SHORTEST_TIME=$(echo $line | cut -f 5 -d "|")                
            fi
            if [[ $LONGEST_TIME -le ${TIMES[$GAMES]} ]]; then
                for (( I = 0; I <= 6; I++ )); do
                    LONGEST_GAME[$I]=$(echo $line | cut -f $((I+1)) -d "|")             # Tomamos la información de la partida más larga.
                done
                LONGEST_TIME=$(echo $line | cut -f 5 -d "|")
            fi

            if [[ $SHORTEST_COLORSEC -ge ${LENGTHS[$GAMES]} ]]; then
                for (( I = 0; I <= 6; I++ )); do
                    SHORTEST_COLORSEC_GAME[$I]=$(echo $line | cut -f $((I+1)) -d "|")   # Tomamos la información de la partida con la secuencia de colores más corta.
                done
                SHORTEST_COLORSEC=$(echo $line | cut -f 6 -d "|")
            fi
            if [[ $LONGEST_COLORSEC -le ${LENGTHS[$GAMES]} ]]; then
                for (( I = 0; I <= 6; I++ )); do
                    LONGEST_COLORSEC_GAME[$I]=$(echo $line | cut -f $((I+1)) -d "|")    # Tomamos la información de la partida con la secuencia de colores más larga.
                done
                NUMCOLOR_SEC_LONGEST=$(echo $line | cut -f 4 -d "|")
                LONGEST_COLORSEC=$(echo $line | cut -f 6 -d "|")                        # Tomamos la longitud de la secuencia de colores de la partida con la secuencia más larga.
                COLOR_SEC_LONGEST=$(echo $line | cut -f 7 -d "|")                       # Tomamos la secuencia de colores de la partida con la secuencia más larga.
            fi

            GAMES=$((GAMES+1))                                                          # Aumentamos el número de partidas jugadas a mediada que leemos cada línea.

        done < $STATS_FILE

        # Si el archivo está vacío, mostramos el error y volvemos al menú principal.
        if [[ GAMES -eq 0 ]]; then
            ERROR=11
            CHECK_ERROR
            SHOW_GUI
        fi

        for (( I = 0; I < $GAMES; I++ )); do
            TOTAL_TIME=$((TOTAL_TIME+(TIMES[$I]))) # Hallamos el tiempo total, resultado de la suma de los tiempos de todas las partidas.
        done

        for (( I = 0; I < $GAMES; I++ )); do
            TOTAL_LENGTH=$((TOTAL_LENGTH+(LENGTHS[$I]))) # Hallamos lalongitud total, resultado de la suma de las longitudes de las secuencias de colores de todas las partidas.
        done


        TIME_AVERAGE=$((TOTAL_TIME/GAMES))  # Hallamos el tiempo medio.
        LENGTH_AVERAGE=$((TOTAL_LENGTH/GAMES))  # Hallamos la longitud media.

        # Sumamos 1 dentro de cada campo de PERCENTS dependiendo del color de la secuencia de la partida con la secuencia más larga.
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
            # Hallamos el número de colores de la secuencia de colores de la partida con la mayor secuencia de colores.
            NUM_PERCENT=$((NUM_PERCENT+1))
        done

        # Evitamos el caso en el que la longitud de la partida con mayor secuencia sea 0
        if [[ NUM_PERCENT -eq 0 ]]; then
            NUM_PERCENT=1
        fi

        for (( I = 0; I <= $NUMCOLOR_SEC_LONGEST; I++ )); do
            PERCENTS[$I]=$(((PERCENTS[$I]*100)/(NUM_PERCENT)))  # Calculamos los porentajes de cada color.
        done

        # Presentamos las estadísticas.
        PRESENT_STATS       

    else
        # En caso de que no exista archivo de log, mostramos el error y sacamos al menú principal.
        ERROR=6
        CHECK_ERROR
        SHOW_GUI
    fi
}
#
# PRESENT_STATS
#
# Función que presenta por pantalla las estadísticas del archivo de log.
#
function PRESENT_STATS
{
    clear
    echo ""

    # Estadísticas generales
    echo -e ${RED}"\t\t    GENERALES\n"${NC}
    echo -e " Número total de partidas jugadas: "${ORANGE}$GAMES${NC}
    echo -e " Media de las longitudes de las secuencias de todas las partidas jugadas: "${ORANGE}$LENGTH_AVERAGE${NC}
    echo -e " Media de los tiempos de todas las partidas jugadas: "${ORANGE}$TIME_AVERAGE${NC}
    echo -e " Tiempo total invertido en todas las partidas: "${ORANGE}$TOTAL_TIME${NC}
    
    # Estadísticas especiales
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

    if test -r $CONFIG_FILE # Comprobamos que el archivo CONFIG_FILE exista.
    then
        while IFS='' read -r line || [[ -n "$line" ]]; do # Lee linea a linea el archivo de configuracion "CONFIG_FILE"

            KEY=$(echo $line | cut -f 1 -d "=")     # KEY almacenará el valor del campo a la izquierda del =
            VALUE=$(echo $line | cut -f 2 -d "=")   # VALUE almacenará el valor del campo a la derecha del =

            case $KEY in
                "NUMCOLORES" ) NUM_COLORS=$VALUE 
                if [[ $NUM_COLORS -gt 4 || $NUM_COLORS -lt 2 ]]; then               # En caso de que el parámetro NUMCOLORES posea un valor no comprendido entre 2 y 4.
                    ERROR=8
                    INCORRECT=1
                fi
                ;;
                "ENTRETIEMPO" ) TIME_BETWEEN=$VALUE
                if [[ $TIME_BETWEEN -lt 1 || $TIME_BETWEEN -gt 4 ]]; then           # En caso de que el parámetro ENTRETIEMPO posea un valor no comprendido entre 1 y 4.
                    ERROR=9
                    INCORRECT=1
                fi    
                ;;
                "ESTADISTICAS" ) STATS_FILE=$VALUE
                STATS_FILE_NAME=$(echo $STATS_FILE | rev | cut -f 1 -d "/" | rev)   # STATS_FILE_NAME contiene el nombre del archivo de log (sin la ruta Ej.: "log.txt")
                if ! test -f $STATS_FILE ; then                                     # En caso de que el directorio no exista.
                    ERROR=10    
                    INCORRECT=1
                fi
                ;;
                *) ERROR=4                                                          # En caso de que el archivo de configuración posea un parámetro desconocido.
                   CHECK_ERROR;;
            esac

        done < $CONFIG_FILE
    else
        # En caso de que no exista archivo de configuración, se preguntará al usuario si desea crearlo.
        ERROR=3
        CHECK_ERROR
        ASK_FOR_CONFIG_FILE_CREATION
    fi
    
    CHECK_ERROR

    # En caso de que alguno de los parametros contenidos en el archivo de configuracion sea incorrecto, se le preguntará al usuario si desea crearlo de nuevo.
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
                INCORRECT=0
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
    LONG_SEC=$((COLOR_NUM-1))
    TIME_PLAYED=$((TIME_FIN-TIME_INIT))

    echo -ne $PID"|"$DATE_AND_TIME"|"$NUM_COLORS"|"$TIME_PLAYED"|"$LONG_SEC"|"  >> $STATS_FILE   
    
    if [[ $LONG_SEC -gt 0 ]]; then
        for (( i = 0; i < COLOR_NUM-2; i++ )); do
            echo -ne ${COLORS[$i]}"-" >> $STATS_FILE
        done

        echo -e ${COLORS[$((COLOR_NUM-1))]} >> $STATS_FILE
    else
        echo "" >> $STATS_FILE
    fi
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
    TIME_TO_SLEEP=1

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
        PRINT_ERROR $ERROR
    fi
}

#
# PRINT_ERROR
#
# Imprime en pantalla un mensaje acerca del error ocurrido.
#
function PRINT_ERROR
{

    clear
    echo -ne ${RED}"\n ERROR "$1": "${BLUE}

    case $ERROR in
        "1")echo -e "(TEST_ARGUMENTS) "${NC}"\n Número incorrecto de argumentos.\n"
            SALIR=1;;
        "2")echo -e "(TEST_ARGUMENTS) "${NC}"\n El argumento es incorrecto.\n"
            sleep 2
            SALIR=1;;
        "3")echo -e "(READ_PARAMETERS) "${NC}"\n El archivo de configuracion no existe o no se puede leer.\n";;
        "4")echo -e "(READ_PARAMETERS) "${NC}"\n Parametro de configuracion no encontrado.\n";;
        "5")echo -e "(SHOW_COLOR) "${NC}"\n Color no especificado.\n"
            SALIR=1;;        
        "6")echo -e "(STATS) "${NC}"\n El archivo de log no existe o no se puede leer.\n"
            sleep 2;;
        "7")echo -e "(STATS) "${NC}"\n Color no especificado.\n"  
            SALIR=1;; 
        "8")echo -e "(READ_PARAMETERS) "${NC}"\n El parámetro NUMCOLORES del archivo "$CONFIG_FILE" es incorrecto.\n";;
        "9")echo -e "(READ_PARAMETERS) "${NC}"\n El parámetro ENTRETIEMPO del archivo "$CONFIG_FILE" es incorrecto.\n";;
        "10")echo -e "(READ_PARAMETERS) "${NC}"\n El parámetro STATS_FILE del archivo "$CONFIG_FILE" es incorrecto o no se encuentra en el directorio del programa.\n";;
        "11")echo -e "(STATS) "${NC}"\n El archivo "$STATS_FILE_NAME" está vacio.\n"
            sleep 2;;
    esac
    ERROR=0
}

###########################################################################################################################################################
###########################################################################################################################################################
#                                                     +-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+                                                       #
#                                                     | IMPRESION | DE | MENSAJES | EN | PANTALLA |                                                       #
#                                                     +-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+-+-+                                                       #
#=========================================================================================================================================================#

function DISPLAY_MENU
{

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

#
# SHOW_GUI
#
# Muestra el menú principal y las opciones asociadas a este.
#
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

###########################################################################################################################################################
###########################################################################################################################################################
#                                                                  +-+-+-+-+                                                                              #
#                                                                  |M|A|I|N|                                                                              #
#                                                                  +-+-+-+-+                                                                              #
#=========================================================================================================================================================#

TEST_ARGUMENTS $*
