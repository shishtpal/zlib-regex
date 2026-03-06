const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // library tests
    const library_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = path(b, "src/all_test.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_library_tests = b.addRunArtifact(library_tests);

    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_library_tests.step);

    // C library
    const staticLib = b.addLibrary(.{
        .name = "regex",
        .root_module = b.createModule(.{
            .root_source_file = path(b, "src/c_regex.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
        .linkage = .static,
    });

    b.installArtifact(staticLib);

    const sharedLib = b.addLibrary(.{
        .name = "regex",
        .root_module = b.createModule(.{
            .root_source_file = path(b, "src/c_regex.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
        .linkage = .dynamic,
    });

    // Skip shared library on Windows due to LLVM dllexport bug
    if (target.result.os.tag != .windows) {
        b.installArtifact(sharedLib);
    }

    // Regex module for Zig examples
    const regex_module = b.addModule("regex", .{
        .root_source_file = path(b, "src/regex.zig"),
    });

    // C examples
    const c_examples_step = b.step("c-examples", "Build all C examples");

    const c_example_files = [_]struct { name: []const u8, src: []const u8 }{
        .{ .name = "example", .src = "example/example.c" },
        .{ .name = "captures-c", .src = "example/captures.c" },
        .{ .name = "validation", .src = "example/validation.c" },
    };

    for (c_example_files) |ex| {
        const c_ex_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        const c_ex = b.addExecutable(.{
            .name = ex.name,
            .root_module = c_ex_module,
        });
        c_ex.root_module.addCSourceFile(.{
            .file = path(b, ex.src),
            .flags = &.{"-Wall"},
        });
        c_ex.root_module.addIncludePath(path(b, "include"));
        c_ex.root_module.linkLibrary(staticLib);
        const install_c_ex = b.addInstallArtifact(c_ex, .{});
        c_examples_step.dependOn(&install_c_ex.step);
    }

    // Zig examples
    const zig_examples_step = b.step("zig-examples", "Build all Zig examples");

    const zig_example_files = [_]struct { name: []const u8, src: []const u8 }{
        .{ .name = "basic", .src = "example/basic.zig" },
        .{ .name = "captures-zig", .src = "example/captures.zig" },
        .{ .name = "search", .src = "example/search.zig" },
        .{ .name = "anchors", .src = "example/anchors.zig" },
        .{ .name = "newlines", .src = "example/newlines.zig" },
    };

    for (zig_example_files) |ex| {
        const zig_ex = b.addExecutable(.{
            .name = ex.name,
            .root_module = b.createModule(.{
                .root_source_file = path(b, ex.src),
                .target = target,
                .optimize = optimize,
            }),
        });
        zig_ex.root_module.addImport("regex", regex_module);
        const install_zig_ex = b.addInstallArtifact(zig_ex, .{});
        zig_examples_step.dependOn(&install_zig_ex.step);
    }

    // Combined examples step
    const examples_step = b.step("examples", "Build all examples (C and Zig)");
    examples_step.dependOn(c_examples_step);
    examples_step.dependOn(zig_examples_step);

    b.default_step.dependOn(test_step);
}

fn path(b: *std.Build, sub_path: []const u8) std.Build.LazyPath {
    if (@hasDecl(std.Build, "path")) {
        // Zig 0.13-dev.267
        return b.path(sub_path);
    } else {
        return .{ .path = sub_path };
    }
}
