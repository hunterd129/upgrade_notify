#!/usr/bin/bash

mkdir -p bin

g++ -std=c++17 -O3 src/main.cpp -o bin/upgrNotif $(pkg-config --cflags --libs libnotify)

mv resources/upgrNotif.service ~/.config/systemd/user/
mv resources/upgrNotif.timer ~/.config/systemd/user/
