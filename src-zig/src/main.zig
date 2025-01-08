const std = @import("std");
const WebView = @import("webview").WebView;

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // 创建 WebView 实例
    const w = WebView.create(false, null);
    defer w.destroy();

    const is_dev: bool = true;
    const path = if (is_dev) "http://localhost:3020" else "./dist/index.html";

    // 打印路径
    std.debug.print("path: {s}\n", .{path});

    // 根据开发模式设置 URL 或本地文件
    if (is_dev) {
        // 使用 navigate 加载开发模式的 URL, 并移除 try 因为 navigate 返回的是 void
        w.navigate(path); // 不使用 try，因为 navigate 没有错误返回
    } else {
        // 生产模式下使用本地文件
        const file = try std.fs.cwd().openFile(path, .{ .read = true });
        defer file.close();
        try w.setFile(file); // 使用 setFile 加载本地文件
    }

    // 设置 WebView 属性
    w.setTitle("Basic Example"); // 移除 try，因为 setTitle 返回的是 void
    w.setSize(480, 320, WebView.WindowSizeHint.None); // 移除 try，因为 setSize 返回的是 void
    w.setHtml("Thanks for using webview!");
    // 运行 WebView
    w.run(); // 移除 try，因为 run 返回的是 void
}
