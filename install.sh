#!/usr/bin/bash
set -e

export AUTOMATE_DIR="$HOME/.config/systemd/user"
export BIN_DIR="$HOME/.local/bin"

mkdir -p "$AUTOMATE_DIR"
mkdir -p "$BIN_DIR"

g++ -std=c++17 -O3 src/main.cpp -o bin/upgrNotif $(pkg-config --cflags --libs libnotify)

cp resources/upgrNotif.service "$AUTOMATE_DIR"
cp resources/upgrNotif.timer "$AUTOMATE_DIR"
cp bin/upgrNotif "$BIN_DIR"

systemctl --user daemon-reload
systemctl --user enable --now upgrNotif.timer
