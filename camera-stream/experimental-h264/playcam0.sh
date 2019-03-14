#!/bin/bash

# https://stackoverflow.com/questions/16658873/how-to-minimize-the-delay-in-a-live-streaming-with-ffmpeg

ffplay -fflags nobuffer -probesize 32 -sync ext -flags low_delay -framedrop udp://10.26.55.10:8888
