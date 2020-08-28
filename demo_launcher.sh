#!/bin/bash

KEYBOARD_EVENT=$(ls -l /dev/input/by-id | grep kbd | grep -o 'event[0-9]' | head -1)
MOUSE_EVENT=$(ls -l /dev/input/by-id | grep mouse | grep -o 'event[0-9]' | head -1)

RIGHT_FOCUS='false'
LEFT_FOCUS='true'

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
            echo kill right_pid
            RIGHT_PID=''
        fi
    elif [ "$LEFT_FOCUS" = 'true' ]; then
        if ( check_pid_exist "$LEFT_PID" ); then
            kill $LEFT_PID
            echo kill left_pid
            LEFT_PID=''
        fi
    fi
 
}

assign_pid()
{   
    echo assign_pid
    echo PID is $1
    if [ "$RIGHT_FOCUS" = 'true' ]; then
        RIGHT_PID="$1"
        echo RIGHT_PID $RIGHT_PID
    elif [ "$LEFT_FOCUS" = 'true' ]; then
        LEFT_PID="$1"
        echo LEFT_PID $LEFT_PID
    fi
}

while true
do
    # Control cursor to left display or right display
    evtest --query /dev/input/$KEYBOARD_EVENT EV_KEY KEY_RIGHT
    if [ $? -eq 10 ]; then
    	echo "KEY_RIGHT pressed"
        for i in `seq 1 6` 
        do
            evemu-play /dev/input/$MOUSE_EVENT < right.evemu
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
            evemu-play /dev/input/$MOUSE_EVENT < left.evemu
            sleep 0.01
        done
        RIGHT_FOCUS='false'
        LEFT_FOCUS='true'
    fi

    # Activate different DEMO App
    evtest --query /dev/input/$KEYBOARD_EVENT EV_KEY KEY_1
    if [ $? -eq 10 ]; then
    	echo "KEY_1 pressed"
        clear_exist_app
        export TEST_FILE=/home/root/movie/bbb-1920x1080-cfg02.mkv
        ( gst-launch-1.0 playbin3 uri=file://$TEST_FILE ) &
        if [ $? -eq 0 ]; then
            assign_pid $!
        fi    
    fi

    evtest --query /dev/input/$KEYBOARD_EVENT EV_KEY KEY_2
    if [ $? -eq 10 ]; then
    	echo "KEY_2 pressed"
        clear_exist_app
        export TEST_FILE=/home/root/movie/honey.mp4
        ( gst-launch-1.0 playbin3 uri=file://$TEST_FILE ) &
        if [ $? -eq 0 ]; then
            assign_pid $!
        fi    
    fi

    evtest --query /dev/input/$KEYBOARD_EVENT EV_KEY KEY_3
    if [ $? -eq 10 ]; then
    	echo "KEY_3 pressed"
        clear_exist_app
        ( glmark2-es2-wayland ) &
        if [ $? -eq 0 ]; then
            assign_pid $!
        fi       
    fi

    evtest --query /dev/input/$KEYBOARD_EVENT EV_KEY KEY_4
    if [ $? -eq 10 ]; then
    	echo "KEY_4 pressed"
        clear_exist_app
        ( /usr/share/cinematicexperience-1.0/Qt5_CinematicExperience ) &
        if [ $? -eq 0 ]; then
            assign_pid $!
        fi    
    fi

    evtest --query /dev/input/$KEYBOARD_EVENT EV_KEY KEY_0
    if [ $? -eq 10 ]; then
    	echo "KEY_0 pressed"
        killall gst-launch-1.0 &
        killall glmark2-es2-wayland &
        killall Qt5_CinematicExperience &
        # test rsync
    fi


    sleep 0.01
done