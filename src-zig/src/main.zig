const std = @import("std");
const WebView = @import("webview").WebView;

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // webview
    const w = WebView.create(false, null);
    defer w.destroy();
    const is_dev: bool = true;
    const path = if (is_dev) "http://localhost:3020" else "./dist/index.html";

    // 修复这里的格式化字符串
    std.debug.print("path: {s}\n", .{path}); // 正确传递 path 变量
    w.setTitle("Basic Example");
    w.setSize(480, 320, WebView.WindowSizeHint.None);
    w.setHtml("Thanks for using webview!");
    w.run();
}
