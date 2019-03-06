from gpiozero import Button
from subprocess import check_call
from signal import pause
from time import sleep,time
import logging, datetime

logging.basicConfig(filename='rpi-poweroff.log',level=logging.DEBUG)

def currentTime():
    currentDT = datetime.datetime.now()
    return currentDT.strftime("%Y-%m-%d %H:%M:%S")

def shutdown():
    logging.info(currentTime() + ": Automatic shutdown initiated.")
    check_call(['sudo', 'poweroff'])

timing = 0.5
shutdownThreshold = 180 / timing # 5 min in iterations

# Will connect to 3.3V out on Rio MXP
# When Rio shutoff DIO will go low
# If low for 3 min shutdown
shutdownButton = Button(21, pull_up=False)
shutDownCounter = 0
everPowered = False

while True:
    isPowered = shutdownButton.is_pressed
    if(not everPowered and isPowered):
        logging.info(currentTime() + ": GPIO high. Waiting for low to shutdown.")
        everPowered = True
    if(not isPowered and everPowered):
        logging.info(currentTime() + ": GPIO Low...")
        shutdownCounter += 1
    else:
        shutdownCounter = 0
    if(shutdownCounter == shutdownThreshold):
        shutdown()
        break
    sleep(timing)
