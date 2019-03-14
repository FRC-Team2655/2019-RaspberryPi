#!/bin/bash

#https://lists.ffmpeg.org/pipermail/ffmpeg-user/2016-January/030127.html

ffmpeg -input_format mjpeg -r 15 -s 640x480 -f v4l2 -i /dev/video0 -c:v libx264 -an -pix_fmt yuv420p -crf 30 -preset:v ultrafast -b:v 730k -tune zerolatency -g 15 -f m4v udp://127.0.0.1:8888
