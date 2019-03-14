# FRC Team 2655 2019 RaspberryPi Setup
Raspberry Pi 2B or newer setup as a co-processor for streaming USB webcam video and processing images.

## Hardware Setup
- Raspberry Pi powered by USB battery pack. A 3.3V linear regulator is connected to DIO pin 26 (and the pi's ground) to from the VRM to serve as a signal to initiate shutdown (see rpi-poweroff.py script).
- Up to four USB webcams can be plugged into the pi. The first two devices are streamed with the camera stream setup (see camera-stream directory). 
- The pi is connected by ethernet to the robot radio.

## Raspberry Pi Software Setup

### Accessing the Pi's filesystem
- SSH access using a text editor such as nano
- VNC access
- Connect to monitor, keyboard, mouse
- Connect SD Card to linux PC

### DD Image
To come

### Manual setup

#### Install Raspbian

#### Enable Remote Access
To enable remote shell access enable the Pi's builtin SSH server. Open Raspberry Pi Configuration and enable SSH under the interfaces tab.

To enable remote desktop access a virtual VNC desktop will be used. A systemd service will be setup to start the virtual VNC server on boot. Create a file in `/etc/systemd/system` called `vncserver@.service` with the following contents.

`/etc/systemd/system/vncserver@.service`
```
[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=forking
User=pi
PAMName=login
PIDFile=/home/pi/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -randr=1366x768,1920x1080,800x600,1024x768 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
```

Run the following command to enable the virtual VNC service on VNC port 1 (port 5901)

```
sudo systemctl daemon-reload && sudo systemctl enable vncserver@1.service
```

To use a different port change the number in the second part of the command (`vncserver@#.service`).

### Network Settings

#### Disable Builtin Wireless
This is only necessary on Pi's with builtin wireless chips (eg. 3B, 3B+, 3A+, Zero W). Per FRC rules both WiFi and Bluetooth *must* be disabled on the Pi.

Edit `/boot/config.txt` and add the following at the bottom of the file

```
dtoverlay=pi3-disable-wifi
dtoverlay=pi3-disable-bt
```

#### Use a Static IP Address
A static IP Address will be required on the field. DNS names are not resolved. A static address between 10.te.am.6 and 10.te.am.10 or between 10.te.am.12 and 10.te.am.19 where te and am are the first two and last two digits of your team number (adding zeros as necessary).

To configure the static IP edit `/etc/dhcpcd.conf` and add the following at the bottom (edit the addresses as necessary).

```
interface eth0 
static ip_address=10.26.55.10 
static routers=10.26.55.1 
static domain_name_servers=10.26.55.1 
```

#### Disabling static address during development

Comment out the above lines (add a hash '#' in front of each).

### Setting Up Required Software

Clone this repo to /home/pi/team2655

If you clone this to a different directory you will have to change paths in the following sections of the setup.

#### Auto Reboot
To automatically initiate a reboot three minutes after DIO 26 goes low (3 minutes in case it happens in the middle of a match) setup a cron job to start the rpi-poweroff script.

Run 
```
crontab -e
```

Choose an editor if prompted and add the following at the end of the file

```
@reboot sleep 20 && python3 /home/pi/team2655/rpi-poweroff.py &
```

This will launch the auto poweroff script 20 seconds after the pi boots.

#### Camera Stream

FFmpeg, and Python3 are required. Make sure to install these packages

```
sudo apt install python3 ffmpeg
```

##### Stream formats
***Only MJPG is currently well supported and tested. Use others with caution!***

###### MJPG (Default)
- Higher bandwidth format
- Lower resultion and framerate to reduce bandwidth usage
- Each stream (2 total) 1024kb/sec at 480x360@15fps
- Easiest to stream/decode (browser, VLC, other)
- Well tested

###### H.264
- Currently High Latency (likely player side)
- Lower bandwidth encoding
- Higher resolution and framerate
- About 512kb/sec 640x480@30fps per stream
- More difficult to stream/decode (ffplay, mplayer, VLC)
- Using FLV or MPEG-TS format
- Poorly tested and not suited for use on robot

###### Experimental H.264
- Only tested local on PC (not on Pi)
- Lower bandwidth encoding
- Higher resolution and framerate
- About 512kb/sec 640x480@30fps (extrapolated)
    - Only tested 640x480@15fps due to test setup limitations
- Low latency
    - Once again, only tested locally. Not yet tested over robot network.
- Using MV4 format
- Poorly tested and not suited for use on robot

##### Start at boot

To start the camera stream at boot setup a cron job. To do so run 

```
crontab -e
```

Select an editor if prompted and add the following to the end of the file

```
@reboot sleep 20 && /home/pi/team2655/camera-stream/start-camerastream.sh &
```

This will start the camera stream 20 seconds after the pi boots. The start script will use the default format listed above. To change the format, use one of the format specific start scripts in the camera-stream subdirectories.
