const std = @import("std");
const print = std.debug.print;
const Regex = @import("regex").Regex;

// Example: Testing complex patterns that may fail to compile

fn testPattern(allocator: std.mem.Allocator, pat: []const u8) void {
    print("Pattern: \"{s}\" => ", .{pat});

    var re = Regex.compile(allocator, pat) catch |err| {
        print("FAIL: {}\n", .{err});
        return;
    };
    defer re.deinit();

    print("OK\n", .{});
}

pub fn main() void {
    const allocator = std.heap.page_allocator;

    print("=== Complex Pattern Tests ===\n\n", .{});

    // Test progressively to isolate the issue
    print("--- Basic character classes ---\n", .{});
    testPattern(allocator, "[A-Z]");
    testPattern(allocator, "[a-z]");
    testPattern(allocator, "[0-9]");
    testPattern(allocator, "[_]");
    testPattern(allocator, "[,;]");

    print("\n--- Combined character classes ---\n", .{});
    testPattern(allocator, "[A-Za-z]");
    testPattern(allocator, "[A-Za-z0-9]");
    testPattern(allocator, "[A-Z_]");
    testPattern(allocator, "[_a-z]");
    testPattern(allocator, "[A-Z_a-z]");
    testPattern(allocator, "[A-Z_a-z0-9]");

    print("\n--- With quantifiers ---\n", .{});
    testPattern(allocator, "[A-Z]*");
    testPattern(allocator, "[A-Z_a-z0-9]*");
    testPattern(allocator, "[,;]*");

    print("\n--- Simple alternation ---\n", .{});
    testPattern(allocator, "a|b");
    testPattern(allocator, "(a|b)");
    testPattern(allocator, "(a*|b*)");
    testPattern(allocator, "([A-Z]*|[a-z]*)");

    print("\n--- The failing pattern ---\n", .{});
    testPattern(allocator, "([A-Z_a-z0-9]*|[,;]*)");

    print("\n--- Variations ---\n", .{});
    testPattern(allocator, "([A-Za-z0-9_]*|[,;]*)");
    testPattern(allocator, "([A-Z]*|[,;]*)");
    testPattern(allocator, "([_]*|[,;]*)");

    // Functional test of the original pattern
    print("\n--- Functional Test ---\n", .{});
    const pat = "([A-Z_a-z0-9]*|[,;]*)";
    var re = Regex.compile(allocator, pat) catch |err| {
        print("Failed to compile: {}\n", .{err});
        return;
    };
    defer re.deinit();

    const test_inputs = [_][]const u8{ "hello", "HELLO_WORLD", "test123", ",;,;", "" };
    print("Pattern: \"{s}\"\n", .{pat});
    for (test_inputs) |input| {
        const result = re.partialMatch(input) catch false;
        print("  \"{s}\" => {}\n", .{ input, result });
    }
}
