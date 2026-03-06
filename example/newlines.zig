const std = @import("std");
const print = std.debug.print;
const Regex = @import("regex").Regex;

// Example: Testing regex matching with newlines

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    print("=== Newline Matching Tests ===\n\n", .{});

    var reg = try Regex.compile(allocator, "a");
    defer reg.deinit();

    // Test cases with newlines
    const test_cases = [_]struct { input: []const u8, name: []const u8 }{
        .{ .input = "a", .name = "\"a\"" },
        .{ .input = "\na", .name = "\"\\na\"" },
        .{ .input = "x\na", .name = "\"x\\na\"" },
        .{ .input = "\n\na", .name = "\"\\n\\na\"" },
        .{ .input = "a\n", .name = "\"a\\n\"" },
    };

    print("Pattern: 'a'\n", .{});
    print("{s:<15} {s:<10} {s:<15}\n", .{ "Input", "match()", "partialMatch()" });
    print("{s:-<15} {s:-<10} {s:-<15}\n", .{ "", "", "" });

    for (test_cases) |tc| {
        const match_result = try reg.match(tc.input);
        const partial_result = try reg.partialMatch(tc.input);
        print("{s:<15} {:<10} {:<15}\n", .{ tc.name, match_result, partial_result });
    }

    print("\n", .{});

    // The specific failing case
    print("Critical test - partialMatch(\"\\na\"): {}\n", .{try reg.partialMatch("\na")});
    print("Expected: true\n", .{});
}
