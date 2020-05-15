#!/bin/bash
while true; do 
    date
    x11vnc -xkb -ncache 0 -forever -display :0 -rfbauth .vnc/passwd
    sleep 10s;
done

	# x11vnc -xkb -usepw 
	# x11vnc -xkb -ncache 0 -forever -display :0 -rfbauth .vnc/passwd 
	# x11vnc -xkb -ncache 0 -forever -localhost -display :0 -rfbauth .vnc/passwd &
