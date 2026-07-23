package main

import (
	"fmt"
	"os/exec"
	"strings"

	"github.com/godbus/dbus/v5"
)

func main() {
	out, _ := exec.Command("checkupdates").Output()

	updateCount := 0
	for _, line := range strings.Split(string(out), "\n") {
		if strings.TrimSpace(line) != "" {
			updateCount++
		}
	}

	body := "System up to date"
	if updateCount > 0 {
		body = fmt.Sprintf("%d updates available", updateCount)
	}

	// Connect directly to the Session Bus (no subprocess required)
	conn, err := dbus.SessionBus()
	if err != nil {
		return
	}
	defer conn.Close()

	obj := conn.Object("org.freedesktop.Notifications", "/org/freedesktop/Notifications")

	// Call org.freedesktop.Notifications.Notify
	// Parameters: app_name, replaces_id, app_icon, summary, body, actions, hints, expire_timeout
	call := obj.Call(
		"org.freedesktop.Notifications.Notify", 0,
		"upgrade_notify",          // app_name
		uint32(0),                 // replaces_id
		"document-save-symbolic",  // app_icon (sender icon!)
		"upgrade_notify",          // summary
		body,                      // body
		[]string{},                // actions
		map[string]dbus.Variant{}, // hints
		int32(-1),                 // expire_timeout (-1 = default)
	)
	_ = call.Err
}
