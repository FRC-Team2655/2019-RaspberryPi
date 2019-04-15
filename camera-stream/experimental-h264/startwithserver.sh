#!/bin/bash

touch /home/pi/camera-server-started.txt

# Make sure to kill background processes on exit
trap "kill 0" EXIT

# Directory of this script
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the syml$
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

HTTPPORT=5805

fuser -k $HTTPPORT/tcp

ffserver -f $DIR/ffserver.conf &
ffmpeg -input_format mjpeg -r 15 -s 640x480 -f v4l2 -i /dev/video0 http://localhost:$HTTPPORT/camera0.ffm &
ffmpeg -input_format mjpeg -r 15 -s 640x480 -f v4l2 -i /dev/video2 http://localhost:$HTTPPORT/camera1.ffm &

wait

