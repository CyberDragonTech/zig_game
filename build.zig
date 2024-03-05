const std = @import("std");
const Sdk = @import("deps/SDL.zig/Sdk.zig");


pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const ziglua_shared: bool = if (optimize != .Debug) true else false;

    const lib = b.addStaticLibrary(.{
        .name = "tests",
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "zig_game",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const ziglua = b.dependency("ziglua", .{
        .target = target,
        .optimize = optimize,
        .version = .lua54,
        .shared = ziglua_shared,
    });
    exe.root_module.addImport("ziglua", ziglua.module("ziglua"));

    const zig_datetime = b.dependency("zig_datetime", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("zig_datetime", zig_datetime.module("zig-datetime"));

    const zigstr = b.dependency("zigstr", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("zigstr", zigstr.module("zigstr"));

    // Create a new instance of the SDL2 Sdk
    const sdk = Sdk.init(b, null);

    sdk.link(exe, .dynamic); // link SDL2 as a shared library
    exe.root_module.addImport("sdl2", sdk.getWrapperModule());
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);


    const lib_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
