const std = @import("std");

const NotifyUrgency = c_int;
const NOTIFY_URGENCY_CRITICAL: NotifyUrgency = 2;

const NotifyNotification = opaque {};

extern fn notify_init(app_name: [*:0]const u8) c_int;
extern fn notify_uninit() void;

extern fn notify_notification_new(
    summary: [*:0]const u8,
    body: ?[*:0]const u8,
    icon: ?[*:0]const u8,
) ?*NotifyNotification;

extern fn notify_notification_set_urgency(
    notification: *NotifyNotification,
    urgency: NotifyUrgency,
) void;

extern fn notify_notification_set_app_icon(
    notification: *NotifyNotification,
    icon: [*:0]const u8,
) void;

extern fn notify_notification_show(
    notification: *NotifyNotification,
    error_out: ?*anyopaque,
) c_int;

extern fn g_object_unref(object: *anyopaque) void;

const Status = struct {
    body: []const u8,
    icon: [:0]const u8,
    owned: bool = false,
};

fn getUpdateStatus(allocator: std.mem.Allocator, io: std.Io) Status {
    const result = std.process.run(allocator, io, .{
        .argv = &.{"checkupdates"},
    }) catch {
        return .{
            .body = "Network error: Failed to establish remote connection",
            .icon = "network-wireless-disabled-symbolic",
        };
    };
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    const exit_code: ?u8 = switch (result.term) {
        .exited => |code| code,
        else => null,
    };

    var line_count: usize = 0;
    var lines = std.mem.tokenizeAny(u8, result.stdout, "\r\n");
    while (lines.next()) |line| {
        if (std.mem.trim(u8, line, " \t").len > 0) {
            line_count += 1;
        }
    }

    if (line_count > 0) {
        const msg = std.fmt.allocPrint(allocator, "{d} updates available", .{line_count}) catch {
            return .{
                .body = "Updates available",
                .icon = "alarm-symbolic",
            };
        };
        return .{
            .body = msg,
            .icon = "alarm-symbolic",
            .owned = true,
        };
    }

    if (exit_code != null and exit_code.? != 0 and exit_code.? != 2 or (exit_code == null and line_count == 0)) {
        return .{
            .body = "Network error: Failed to establish remote connection",
            .icon = "network-wireless-disabled-symbolic",
        };
    }

    return .{
        .body = "System up to date",
        .icon = "alarm-symbolic",
    };
}

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;

    if (notify_init("Upgrade Notify") == 0) {
        return error.NotifyInitFailed;
    }
    defer notify_uninit();

    const status = getUpdateStatus(allocator, io);
    defer if (status.owned) allocator.free(status.body);

    const body_z = try allocator.dupeSentinel(u8, status.body, 0);
    defer allocator.free(body_z);

    const notification = notify_notification_new(
        "Upgrade Notify",
        body_z.ptr,
        status.icon.ptr,
    ) orelse return error.NotificationCreateFailed;
    defer g_object_unref(@ptrCast(notification));

    notify_notification_set_urgency(notification, NOTIFY_URGENCY_CRITICAL);
    notify_notification_set_app_icon(notification, "document-save-symbolic");
    _ = notify_notification_show(notification, null);
}
