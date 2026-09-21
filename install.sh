#!/usr/bin/bash

g++ -std=c++17 -O3 src/main.cpp -o bin/upgrNotif $(pkg-config --cflags --libs libnotify)
