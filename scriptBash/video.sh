#!/bin/bash
xrandr --newmode "2560x1080"  188.75  2560 2712 2976 3392  1080 1083 1093 1114 -hsync +vsync
xrandr --addmode HDMI-1 2560x1080
xrandr -s 2560x1080

