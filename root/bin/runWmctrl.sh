#!/bin/bash

while true; do 
	wmctrl -l -x -G > ~/Documents/HIST/win_`date +%Y%m%d-%H%M%S`.txt
	sleep 1h;
done
