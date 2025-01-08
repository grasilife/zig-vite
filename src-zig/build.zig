const std = @import("std");

// 虽然这个函数看起来是命令式的，但请注意，它的工作是
// 声明性地构建一个将由外部运行器执行的构建图。
pub fn build(b: *std.Build) void {
    // 标准目标选项允许运行 `zig build` 的人选择
    // 构建目标平台。在这里，我们没有覆盖默认设置，
    // 这意味着允许任何目标，默认目标是本地平台。其他用于
    // 限制支持的目标集的选项也是可用的。
    const target = b.standardTargetOptions(.{});

    // 标准优化选项允许运行 `zig build` 的人选择
    // 在 Debug、ReleaseSafe、ReleaseFast 和 ReleaseSmall 之间进行选择。
    // 在这里我们没有设置首选的发布模式，允许用户自行决定如何优化。
    const optimize = b.standardOptimizeOption(.{});

    // 添加一个静态库
    const lib = b.addStaticLibrary(.{
        .name = "zip-app", // 库的名称
        // 在此情况下，主源文件仅是一个路径，但是在更复杂的构建脚本中，
        // 这可能是一个生成的文件。
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // 这声明了在用户执行 "install" 步骤时（运行 `zig build` 时的默认步骤），
    // 将库安装到标准位置。
    b.installArtifact(lib);

    // 添加一个可执行文件
    const exe = b.addExecutable(.{
        .name = "zip-app", // 可执行文件的名称
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const webview = b.dependency("webview", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("webview", webview.module("webview"));
    exe.linkLibrary(webview.artifact("webviewStatic")); // or "webviewShared" for shared library
    // exe.linkSystemLibrary("webview"); to link with installed prebuilt library without building
    // 这声明了在用户执行 "install" 步骤时，将可执行文件安装到
    // 标准位置。
    b.installArtifact(exe);

    // 这*创建*了一个运行步骤，当另一个步骤依赖于它时，将执行此步骤。
    // 下面的代码会建立这样一个依赖关系。
    const run_cmd = b.addRunArtifact(exe);

    // 通过使运行步骤依赖于安装步骤，它将从安装目录运行，而不是直接
    // 从缓存目录运行。这不是必需的，但如果应用程序依赖于其他已安装的
    // 文件，这确保它们将按预期存在并位于正确的位置。
    run_cmd.step.dependOn(b.getInstallStep());

    // 这允许用户在构建命令中传递应用程序参数，例如：`zig build run -- arg1 arg2 等等`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // 这创建了一个构建步骤。它将在 `zig build --help` 菜单中可见，
    // 并且可以像这样选择：`zig build run`。
    // 这将评估 `run` 步骤，而不是默认的 "install" 步骤。
    const run_step = b.step("run", "运行应用程序");
    run_step.dependOn(&run_cmd.step);

    // 创建一个单元测试步骤。它只构建测试可执行文件，
    // 但不会执行它。
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // 类似于先前创建的 run 步骤，这将把 `test` 步骤暴露到
    // `zig build --help` 菜单中，提供一种方法让用户请求
    // 运行单元测试。
    const test_step = b.step("test", "运行单元测试");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
