# Minimal raspbian setup for camera streams only

## Features
- Streams cameras w/ H.264 using ffserver (Raspbian stretch)
- Static IP address
- Disabled wireless communication
- NO VISION SUPPORT!!!

## Setup Instructions
- Download and install an older Raspbian Stretch image [https://downloads.raspberrypi.org/raspbian/images/raspbian-2019-04-09/2019-04-08-raspbian-stretch.zip](https://downloads.raspberrypi.org/raspbian/images/raspbian-2019-04-09/2019-04-08-raspbian-stretch.zip)
- Use etcher to flash the image to an SD Card

- Connect the SD Card to a PC (any OS should work) and edit the config.txt file on the boot parition. Add the following lines at the end of the file (these disable wifi and bluetooth so that it is legal on the field).

```
dtoverlay=pi3-disable-wifi
dtoverlay=pi3-disable-bt
```

- Install required software

```
sudo apt install ffmpeg git python3
```

- Make sure ffmpeg and ffserver commands exist.

```
which ffmpeg
which ffserver
```

- Clone the git repo to `~/team2655`

```
https://github.com/FRC-Team2655/2019-RaspberryPi.git ~/team2655
```

- Start camera streams at boot (this script will use the experimental h.264 configuration which is the right one).

```
crontab -e
```

This will open a file. If asked about a text editor choose nano. Add the following line at the end

```
@reboot sleep 20 && /home/pi/team2655/camera-stream/start-camerastream.sh &
```

This will run the `start-camerastream.sh` script 20 seconds after booting the pi.

The script is currently setup to run one of the experimental h264 scripts which starts ffserver and then ffmpeg on two cameras. The camera devices may need to change in the `~/team2655/camera-stream/experimental-h264/startwithserver.sh` script. The only thing that would need to change would be the `/dev/video` numbers in the two ffmpeg commands in the script.

- Finally set a static IP. Edit `/etc/dhcpcd.conf` and add the following lines

```
interface eth0 
static ip_address=10.26.55.10 
static routers=10.26.55.1 
static domain_name_servers=10.26.55.1
```