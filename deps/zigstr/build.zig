const Build = @import("std").Build;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Deps
    const ziglyph = b.dependency("ziglyph", .{
        .target = target,
        .optimize = optimize,
    });

    const cow_list = b.dependency("cow_list", .{
        .target = target,
        .optimize = optimize,
    });

    // Export module
    const zigstr = b.addModule("zigstr", .{
        .root_source_file = .{ .path = "src/Zigstr.zig" },
    });

    zigstr.addImport("cow_list", cow_list.module("cow_list"));
    zigstr.addImport("ziglyph", ziglyph.module("ziglyph"));

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    main_tests.root_module.addImport("cow_list", cow_list.module("cow_list"));
    main_tests.root_module.addImport("ziglyph", ziglyph.module("ziglyph"));

    const run_tests = b.addRunArtifact(main_tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_tests.step);
}
