#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo -e "\n------------------ startup of Xfce4 window manager ------------------"

### disable screensaver and power management
xset -dpms &
xset s noblank &
xset s off &

/usr/bin/startxfce4 --replace > $HOME/wm.log & 
dockerize -wait tcp://ody-rabbit:5672 -timeout 50s && 
/headless/Desktop/ExecutableSketch/SimpleOrganisms_Evolution &
sleep 1
cat $HOME/wm.log
