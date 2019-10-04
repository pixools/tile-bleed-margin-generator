#!/bin/bash

if [ $# -lt 3 ]
  then
    echo "usage: SOURCE DESTINATION TILEWIDTH [TILEHEIGHT]"
    exit
fi

sourcepath=$1
destpath=$2
tilew=$3
tileh=${4:-$3}

sourcew=`identify -format %w $sourcepath`
sourceh=`identify -format %h $sourcepath`
columns=$(($sourcew / $tilew))
rows=$(($sourceh / $tileh))
newtilew=$(($tilew + 2))
newtileh=$(($tileh + 2))

convert -crop ${tilew}x${tileh} $sourcepath -define distort:viewport=${newtilew}x${newtileh}-1-1 -filter point -distort SRT 0 +repage miff:- |
montage - -tile ${columns}x${rows} -geometry +0+0 -background none $destpath
