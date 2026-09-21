#include <string>
#include <memory>
#include <array>
#include <sstream>
#include <utility>
#include <libnotify/notify.h>

struct PcloseDeleter {
    void operator()(FILE* pipe) const {
        if (pipe) {
            pclose(pipe);
        }
    }
};

std::pair<std::string, std::string> get_update_status() {
    std::array<char, 4096> buffer;
    std::string result;

    std::unique_ptr<FILE, PcloseDeleter> pipe(
            popen("checkupdates 2>/dev/null", "r")
            );

    if (!pipe) {
        return {"Network error: Failed to establish remote connection", "network-wireless-disabled-symbolic"};
    }

    size_t line_count = 0;
    while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
        result += buffer.data();
    }

    int status = pclose(pipe.release());

    std::istringstream stream(result);
    std::string line;
    while (std::getline(stream, line)) {
        if (!line.empty() && line.find_first_not_of(" \t\n\r") != std::string::npos) {
            line_count++;
        }
    }

    if (status != 0 && line_count == 0) {
        return {"Network error: Failed to establish remote connection", "network-wireless-disabled-symbolic"};
    }

    if (line_count > 0) {
        return {std::to_string(line_count) + " updates available", "alarm-symbolic"};
    }

    return {"System up to date", "alarm-symbolic"};
}

int main() {
    if (!notify_init("Upgrade Notify")) {
        return 1;
    }

    auto [body, image_path] = get_update_status();

    NotifyNotification *notification = notify_notification_new(
        "Upgrade Notify", body.c_str(), "document-save-symbolic");

    notify_notification_set_urgency(notification, NOTIFY_URGENCY_CRITICAL);

    GVariant *image_path_variant = g_variant_new_string(image_path.c_str());
    notify_notification_set_hint(notification, "image-path", image_path_variant);

    notify_notification_show(notification, nullptr);

    g_object_unref(G_OBJECT(notification));
    notify_uninit();

    return 0;
}
