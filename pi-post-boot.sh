#!/bin/bash

# things I run on a Raspberry Pi after boot

# I don't put this in anything that runs automatically at boot time, since I want to see that the Pi is running normally first.
# The LEDs are handy for that, and since I tend to run Pis headless, it's useful to leave the HDMI port on, in case I need to
# plug in a display to see what's going on if a Pi is unreachable after boot.
#
# Nothing original here - just a couple of things to run manually to save power after boot time. Comment or uncomment lines as needed.

# turn off the HDMI port to save power
# note: this works in Buster or earlier - not Bullseye (might work if using dtoverlay=vc4-fkms-v3d in /boot/config.txt)
#/opt/vc/bin/tvservice --off

### configure LEDs for B-sized Pis like the 2B, 3A+, 4B

# Turn the power LED off (0) or on (1) - for 5.x kernels and prior
#echo none | sudo tee /sys/class/leds/led0/trigger
#echo 0 | sudo tee /sys/class/leds/led0/brightness
#echo none | sudo tee /sys/class/leds/led1/trigger
#echo 0 | sudo tee /sys/class/leds/led1/brightness

# Turn the power LED off (0) or on (255) - for 6.x kernels
echo none | sudo tee /sys/class/leds/PWR/trigger
echo 0 | sudo tee /sys/class/leds/PWR/brightness

# Optional: set the power LED to GPIO mode (set 'off' by default)
#echo gpio | sudo tee /sys/class/leds/led1/trigger

# Optional: use the power LED for 'under-voltage detect' mode
#echo input | sudo tee /sys/class/leds/led1/trigger

# Optional: set the activity LED to trigger on cpu0 instead of mmc0 (SD card access)
#echo cpu0 | sudo tee /sys/class/leds/led0/trigger

### comment the above and uncomment the 'echo' lines below to configure LEDs for a Pi Zero

# Set the Pi Zero activity LED trigger to 'none' - kernels 5.x and earlier
#echo none | sudo tee /sys/class/leds/led0/trigger
# Turn off the Pi Zero activity LED.
#echo 0 | sudo tee /sys/class/leds/led0/brightness

# Set the Pi Zero activity LED trigger to 'none' - kernel 6.x
#echo none | sudo tee /sys/class/leds/ACT/trigger
# Turn off the Pi Zero activity LED.
#echo 0 | sudo tee /sys/class/leds/ACT/brightness
