package main

import (
	"fmt"
	"os/exec"
	"strings"

	"github.com/godbus/dbus/v5"
)

func main() {
	out, err := exec.Command("checkupdates").Output()

	var body string
	if err != nil {
		body = "Network error: failed to establish remote connection"
	} else {
		updateCount := 0
		for _, line := range strings.Split(string(out), "\n") {
			if strings.TrimSpace(line) != "" {
				updateCount++
			}
		}

		if updateCount > 0 {
			body = fmt.Sprintf("%d updates available", updateCount)
		} else {
			body = "System up to date"
		}
	}

	conn, err := dbus.SessionBus()
	if err != nil {
		return
	}
	defer conn.Close()

	obj := conn.Object("org.freedesktop.Notifications", "/org/freedesktop/Notifications")

	_ = obj.Call(
		"org.freedesktop.Notifications.Notify", 0,
		"Upgrade Notify",
		uint32(0),
		"document-save-symbolic",
		"Upgrade Notify",
		body,
		[]string{},
		map[string]dbus.Variant{},
		int32(-1),
	)
}
