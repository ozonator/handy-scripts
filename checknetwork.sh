#!/bin/bash

# a short script to check if a network connection is up and working, and restore it if not
#
# Why? I have a Pi Zero W that's in a spot that doesn't get a strong wifi signal - sometimes,
# it becomes unreachable, which seems to be related to it not staying connected to wifi.
# This script seems to do the trick. I run it from /etc/crontab once an hour:
# 3  *	* * *   root	/usr/local/bin/checknetwork.sh

# see if we can reach the gateway (or some other reliable local device)
/bin/ping -c4 10.0.1.1 > /dev/null
 
if [ $? != 0 ] 
then
  #nuclear option
  #sudo /sbin/shutdown -r now

  echo "No network connection, restarting wlan0"
  
  #one way...
  #/sbin/ifdown 'wlan0'
  #sleep 5
  #/sbin/ifup --force 'wlan0'

  # another way...
  /bin/systemctl restart networking
fi
