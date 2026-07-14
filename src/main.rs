use notify_rust::Notification;
use std::process::Command;

fn main() {
    // 1. Run checkupdates
    let output = Command::new("checkupdates")
        .output()
        .expect("Failed to execute checkupdates");

    let stdout_str = String::from_utf8_lossy(&output.stdout);

    // 2. Count the non-empty lines
    let update_count = stdout_str
        .lines()
        .filter(|line| !line.trim().is_empty())
        .count();

    // 3. Format the body message
    let body_msg = if update_count > 0 {
        format!("{} updates available", update_count)
    } else {
        "System up to date".to_string()
    };

    // 4. Dispatch natively over D-Bus
    Notification::new()
        .appname("upgrade_notify") // Sets the header identity
        .icon("document-save-symbolic") // Sets the symbolic arrow header icon
        .summary("upgrade_notify") // Bold headline
        .body(&body_msg) // Subtext
        .show()
        .expect("Failed to send D-Bus notification");
}
