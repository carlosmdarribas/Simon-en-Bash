#!/bin/sh

#  saimon.sh
#  TrabajoSSOOI_I
#
#  Created by Güe Both on 31/10/18.
#  

#! /bin/bash



function TEST_ARGUMENTS {
    if [[ $# -lt 2 ]]; then
        if [[ $# -eq 1 ]]; then
            if [[ $1 = "-g"  ]]; then
                SHOW_GROUP_DATA;
            else
                ERROR=2
                ALLOWED_ARGUMENTS
            fi
        else
            EXECUTE_GAME;
        fi
    else
        ERROR=1
    fi
}

function SHOW_GROUP_DATA {
    echo "Er Gonza y er Carlo han hesho eto" # DEBUG: Modificar en producción
}

function SHOW_MENU {
    echo " J)JUGAR\nC)CONFIGURACIÓN\nE)ESTADÍSTICAS\nS)SALIR\n“Saimon”. Introduzca una opción >>"
}
###########################################################################################################################################################
###########################################################################################################################################################
#                                                     +-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+                                                                      #
#                                                     |F|U|N|C|I|O|N| |P|R|I|N|C|I|P|A|L|                                                                      #
#                                                     +-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+                                                                      #
#=========================================================================================================================================================#

ERROR=0 #0 = No errors

TEST_ARGUMENTS $1 $2
