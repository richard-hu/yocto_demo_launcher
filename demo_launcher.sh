#!/bin/bash

#################################################################################
# Copyright 2019 Technexion Ltd.
#
# Author: Richard Hu <richard.hu@technexion.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#################################################################################

KEYBOARD_EVENT=$(ls -l /dev/input/by-id | grep kbd | grep -o 'event[0-9]' | head -1)
MOUSE_EVENT=$(ls -l /dev/input/by-id | grep mouse | grep -o 'event[0-9]' | head -1)

RIGHT_FOCUS='false'
LEFT_FOCUS='true'

EXEC_PATH=$(dirname "$0")

check_pid_exist()
{
    #echo 'inside check_pid_exist'
    if [ -z "$1" ]; then
        #echo 'empty PID'
        return 1
    elif (ps -p "$1" > /dev/null 2>&1 ); then
        #echo 'PID exist'
        return 0
    else
        #echo 'PID not exist'
        return 1
    fi
}

clear_exist_app()
{
    echo clear_exit_app
    echo RIGHT_FOCUS $RIGHT_FOCUS
    echo LEFT_FOCUS $LEFT_FOCUS
    if [ "$RIGHT_FOCUS" = 'true' ]; then
        if ( check_pid_exist "$RIGHT_PID" ); then
            kill $RIGHT_PID
            echo kill right_pid $RIGHT_PID
            RIGHT_PID=''
        fi
    elif [ "$LEFT_FOCUS" = 'true' ]; then
        if ( check_pid_exist "$LEFT_PID" ); then
            kill $LEFT_PID
            echo kill left_pid $LEFT_PID
            LEFT_PID=''
        fi
    fi
 
}

assign_pid()
{   
    echo assign_pid
    echo PID is "$1"
    if [ "$RIGHT_FOCUS" = 'true' ]; then
        RIGHT_PID="$1"
        echo RIGHT_PID $RIGHT_PID
    elif [ "$LEFT_FOCUS" = 'true' ]; then
        LEFT_PID="$1"
        echo LEFT_PID $LEFT_PID
    fi
}


# parameter: 1. key_code 2. APP_NAME
start_demo_app ()
{
    evtest --query /dev/input/$KEYBOARD_EVENT EV_KEY "$1"
    if [ $? -eq 10 ]; then
        echo ""$1" pressed"
        clear_exist_app
        if [ -n "$2" ]; then
            eval ""$2" &"
            if [ $? -eq 0 ]; then
                assign_pid "$!"
            fi
        fi
    fi
}

echo ########################################################
echo Start DEMP APP
echo ########################################################

while true
do
    # Control cursor to left display or right display
    evtest --query /dev/input/$KEYBOARD_EVENT EV_KEY KEY_RIGHT
    if [ $? -eq 10 ]; then
    	echo "KEY_RIGHT pressed"
        for i in `seq 1 6` 
        do
            evemu-play /dev/input/$MOUSE_EVENT < $EXEC_PATH/right.evemu
            sleep 0.01
        done
        RIGHT_FOCUS='true'
        LEFT_FOCUS='false'
    fi

    evtest --query /dev/input/$KEYBOARD_EVENT EV_KEY KEY_LEFT
    if [ $? -eq 10 ]; then
    	echo "KEY_LEFT pressed"
        for i in `seq 1 6`
        do
            evemu-play /dev/input/$MOUSE_EVENT < $EXEC_PATH/left.evemu
            sleep 0.01
        done
        RIGHT_FOCUS='false'
        LEFT_FOCUS='true'
    fi

    # Activate different DEMO App
    start_demo_app "KEY_1" 'gst-launch-1.0 playbin3 uri=file:///home/root/movie/bbb-1920x1080-cfg02.mkv'

    start_demo_app "KEY_2" 'gst-launch-1.0 playbin3 uri=file:///home/root/movie/ink.mp4'

    start_demo_app "KEY_3" "glmark2-es2-wayland"

    start_demo_app "KEY_4" "/usr/share/cinematicexperience-1.0/Qt5_CinematicExperience"

    start_demo_app "KEY_5" "/usr/share/qt5nmapper-1.0/Qt5_NMapper"

    start_demo_app "KEY_6" "/usr/share/qt5nmapcarousedemo-1.0/Qt5_NMap_CarouselDemo"

    start_demo_app "KEY_7" "/usr/share/qt5everywheredemo-1.0/QtDemo"

    start_demo_app "KEY_ESC"

    #sleep 0.01
done