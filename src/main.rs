use notify_rust::Notification;
use std::process::Command;

fn main() {
    let output = Command::new("checkupdates")
        .output()
        .expect("Failed to execute checkupdates");

    let stdout_str = String::from_utf8_lossy(&output.stdout);
    
    let update_count = stdout_str
        .lines()
        .filter(|line| !line.trim().is_empty())
        .count();
    
    let body_msg = if update_count > 0 {
        format!("{} updates available", update_count)
    } else {
        "System up to date".to_string()
    };

    Notification::new()
        .appname("upgrade_notify")
        .icon("document-save-symbolic")
        .summary("upgrade_notify")
        .body(&body_msg)
        .show()
        .expect("Failed to send D-Bus notification");
}
