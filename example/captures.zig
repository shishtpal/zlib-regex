const std = @import("std");
const debug = std.debug;
const mem = std.mem;
const Regex = @import("regex").Regex;

// Example: Working with capture groups in Zig

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    debug.print("=== Capture Groups Example ===\n\n", .{});

    // Example 1: Extract parts of a date
    {
        debug.print("--- Date Parsing ---\n", .{});
        const input = "Meeting scheduled for 2024-12-25 at 3pm";
        debug.print("Input: \"{s}\"\n", .{input});

        var re = try Regex.compile(allocator, "([0-9]{4})-([0-9]{2})-([0-9]{2})");
        defer re.deinit();

        if (try re.captures(input)) |*caps| {
            defer @constCast(caps).deinit();

            debug.print("Full match: \"{s}\"\n", .{caps.sliceAt(0) orelse "none"});
            debug.print("Year:       \"{s}\"\n", .{caps.sliceAt(1) orelse "none"});
            debug.print("Month:      \"{s}\"\n", .{caps.sliceAt(2) orelse "none"});
            debug.print("Day:        \"{s}\"\n", .{caps.sliceAt(3) orelse "none"});

            // Also show the bounds
            if (caps.boundsAt(0)) |span| {
                debug.print("Match position: [{d}, {d})\n", .{ span.lower, span.upper });
            }
        }
        debug.print("\n", .{});
    }

    // Example 2: Parse a URL-like pattern
    {
        debug.print("--- URL Parsing ---\n", .{});
        const input = "Visit https://example.com:8080/path for more info";
        debug.print("Input: \"{s}\"\n", .{input});

        // Pattern: (protocol)://(host):(port)/(path)
        var re = try Regex.compile(allocator, "(https?)://([a-zA-Z0-9.]+):([0-9]+)/([a-zA-Z0-9/]+)");
        defer re.deinit();

        if (try re.captures(input)) |*caps| {
            defer @constCast(caps).deinit();

            debug.print("Protocol: \"{s}\"\n", .{caps.sliceAt(1) orelse "none"});
            debug.print("Host:     \"{s}\"\n", .{caps.sliceAt(2) orelse "none"});
            debug.print("Port:     \"{s}\"\n", .{caps.sliceAt(3) orelse "none"});
            debug.print("Path:     \"{s}\"\n", .{caps.sliceAt(4) orelse "none"});
        }
        debug.print("\n", .{});
    }

    // Example 3: Extract key-value pairs
    {
        debug.print("--- Key-Value Extraction ---\n", .{});
        const inputs = [_][]const u8{
            "name=John",
            "age=30",
            "city=NYC",
        };

        var re = try Regex.compile(allocator, "([a-zA-Z]+)=([a-zA-Z0-9]+)");
        defer re.deinit();

        for (inputs) |input| {
            if (try re.captures(input)) |*caps| {
                defer @constCast(caps).deinit();

                const key = caps.sliceAt(1) orelse "?";
                const value = caps.sliceAt(2) orelse "?";
                debug.print("  {s} => {s}\n", .{ key, value });
            }
        }
        debug.print("\n", .{});
    }

    // Example 4: Nested groups
    {
        debug.print("--- Nested Groups ---\n", .{});
        const input = "abc123xyz";
        debug.print("Input: \"{s}\"\n", .{input});
        debug.print("Pattern: ((abc)(123))(xyz)\n", .{});

        var re = try Regex.compile(allocator, "((abc)([0-9]+))(xyz)");
        defer re.deinit();

        if (try re.captures(input)) |*caps| {
            defer @constCast(caps).deinit();

            debug.print("Group 0 (full):  \"{s}\"\n", .{caps.sliceAt(0) orelse "none"});
            debug.print("Group 1 (abc+#): \"{s}\"\n", .{caps.sliceAt(1) orelse "none"});
            debug.print("Group 2 (abc):   \"{s}\"\n", .{caps.sliceAt(2) orelse "none"});
            debug.print("Group 3 (123):   \"{s}\"\n", .{caps.sliceAt(3) orelse "none"});
            debug.print("Group 4 (xyz):   \"{s}\"\n", .{caps.sliceAt(4) orelse "none"});

            debug.print("\nTotal captures: {d}\n", .{caps.len()});
        }
    }

    debug.print("\n=== Done ===\n", .{});
}
