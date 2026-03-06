const std = @import("std");
const debug = std.debug;
const mem = std.mem;
const Regex = @import("regex").Regex;

// Example: Searching and finding patterns in text

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    debug.print("=== Pattern Searching Example ===\n\n", .{});

    // Example 1: Find all numbers in text (manual iteration)
    {
        debug.print("--- Finding Numbers ---\n", .{});
        const text = "Order #1234 contains 5 items at $99 each, total $495";
        debug.print("Text: \"{s}\"\n", .{text});
        debug.print("Numbers found: ", .{});

        var re = try Regex.compile(allocator, "[0-9]+");
        defer re.deinit();

        var pos: usize = 0;
        var first = true;
        while (pos < text.len) {
            if (try re.captures(text[pos..])) |*caps| {
                defer @constCast(caps).deinit();

                if (caps.boundsAt(0)) |span| {
                    if (!first) debug.print(", ", .{});
                    first = false;
                    debug.print("{s}", .{caps.sliceAt(0) orelse ""});
                    pos += span.upper;
                    if (span.upper == 0) pos += 1; // prevent infinite loop
                } else break;
            } else break;
        }
        debug.print("\n\n", .{});
    }

    // Example 2: Match vs PartialMatch comparison
    {
        debug.print("--- match() vs partialMatch() ---\n", .{});
        const inputs = [_][]const u8{
            "hello",
            "hello world",
            "say hello",
            "say hello world",
        };

        var re = try Regex.compile(allocator, "hello");
        defer re.deinit();

        debug.print("Pattern: 'hello'\n", .{});
        debug.print("{s:<20} {s:<10} {s:<15}\n", .{ "Input", "match()", "partialMatch()" });
        debug.print("{s:-<20} {s:-<10} {s:-<15}\n", .{ "", "", "" });

        for (inputs) |input| {
            const match_result = try re.match(input);
            const partial_result = try re.partialMatch(input);
            debug.print("{s:<20} {:<10} {:<15}\n", .{
                input,
                match_result,
                partial_result,
            });
        }
        debug.print("\n", .{});
    }

    // Example 3: Validate multiple inputs
    {
        debug.print("--- Input Validation ---\n", .{});

        const TestCase = struct { input: []const u8, expected: bool };

        const Pattern = struct {
            name: []const u8,
            pattern: []const u8,
            test_cases: []const TestCase,
        };

        const email_tests = [_]TestCase{
            .{ .input = "user@example.com", .expected = true },
            .{ .input = "test.email@domain.org", .expected = true },
            .{ .input = "invalid-email", .expected = false },
            .{ .input = "@nodomain.com", .expected = false },
        };

        const hex_tests = [_]TestCase{
            .{ .input = "0xFF", .expected = true },
            .{ .input = "0x1234abcd", .expected = true },
            .{ .input = "xFF", .expected = false },
            .{ .input = "0xGHI", .expected = false },
        };

        const patterns = [_]Pattern{
            .{
                .name = "Email (simple)",
                .pattern = "[a-zA-Z0-9.]+@[a-zA-Z0-9]+\\.[a-zA-Z]+",
                .test_cases = &email_tests,
            },
            .{
                .name = "Hex number",
                .pattern = "0x[0-9a-fA-F]+",
                .test_cases = &hex_tests,
            },
        };

        for (patterns) |p| {
            debug.print("Pattern: {s}\n", .{p.name});
            var re = try Regex.compile(allocator, p.pattern);
            defer re.deinit();

            for (p.test_cases) |tc| {
                const result = try re.partialMatch(tc.input);
                const status = if (result == tc.expected) "OK" else "FAIL";
                debug.print("  {s:<25} => {s:<5} [{s}]\n", .{
                    tc.input,
                    if (result) "match" else "no",
                    status,
                });
            }
            debug.print("\n", .{});
        }
    }

    // Example 4: Log line parsing
    {
        debug.print("--- Log Line Parsing ---\n", .{});
        const log_lines = [_][]const u8{
            "[2024-01-15 10:30:45] INFO: Server started",
            "[2024-01-15 10:31:02] ERROR: Connection failed",
            "[2024-01-15 10:31:15] WARN: High memory usage",
        };

        // Pattern: [date time] level: message
        var re = try Regex.compile(allocator, "\\[([0-9-]+) ([0-9:]+)\\] ([A-Z]+): (.+)");
        defer re.deinit();

        for (log_lines) |line| {
            if (try re.captures(line)) |*caps| {
                defer @constCast(caps).deinit();

                const date = caps.sliceAt(1) orelse "?";
                const time = caps.sliceAt(2) orelse "?";
                const level = caps.sliceAt(3) orelse "?";
                const msg = caps.sliceAt(4) orelse "?";

                debug.print("Date: {s}, Time: {s}, Level: {s}\n", .{ date, time, level });
                debug.print("  Message: {s}\n", .{msg});
            }
        }
    }

    debug.print("\n=== Done ===\n", .{});
}
