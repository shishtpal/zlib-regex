const std = @import("std");
const debug = std.debug;
const Regex = @import("regex").Regex;

// Example: Basic regex matching in Zig

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    debug.print("=== Basic Regex Matching ===\n\n", .{});

    // Example 1: Simple word matching
    {
        var re = try Regex.compile(allocator, "hello");
        defer re.deinit();

        debug.print("Pattern: 'hello'\n", .{});
        debug.print("  match(\"hello\")        = {}\n", .{try re.match("hello")});
        debug.print("  match(\"hello world\")  = {}\n", .{try re.match("hello world")});
        debug.print("  partialMatch(\"say hello\") = {}\n\n", .{try re.partialMatch("say hello")});
    }

    // Example 2: Character classes
    {
        debug.print("Character Classes:\n", .{});

        var digit_re = try Regex.compile(allocator, "\\d+");
        defer digit_re.deinit();
        debug.print("  '\\\\d+' matches \"abc123def\": {}\n", .{try digit_re.partialMatch("abc123def")});

        var word_re = try Regex.compile(allocator, "\\w+");
        defer word_re.deinit();
        debug.print("  '\\\\w+' matches \"hello_world\": {}\n", .{try word_re.match("hello_world")});

        var space_re = try Regex.compile(allocator, "\\s+");
        defer space_re.deinit();
        debug.print("  '\\\\s+' matches \"   \": {}\n\n", .{try space_re.match("   ")});
    }

    // Example 3: Quantifiers
    {
        debug.print("Quantifiers:\n", .{});

        var star_re = try Regex.compile(allocator, "ab*c");
        defer star_re.deinit();
        debug.print("  'ab*c' matches \"ac\":   {}\n", .{try star_re.match("ac")});
        debug.print("  'ab*c' matches \"abc\":  {}\n", .{try star_re.match("abc")});
        debug.print("  'ab*c' matches \"abbc\": {}\n", .{try star_re.match("abbc")});

        var plus_re = try Regex.compile(allocator, "ab+c");
        defer plus_re.deinit();
        debug.print("  'ab+c' matches \"ac\":   {}\n", .{try plus_re.match("ac")});
        debug.print("  'ab+c' matches \"abc\":  {}\n", .{try plus_re.match("abc")});

        var opt_re = try Regex.compile(allocator, "colou?r");
        defer opt_re.deinit();
        debug.print("  'colou?r' matches \"color\":  {}\n", .{try opt_re.match("color")});
        debug.print("  'colou?r' matches \"colour\": {}\n\n", .{try opt_re.match("colour")});
    }

    // Example 4: Character sets and ranges
    {
        debug.print("Character Sets:\n", .{});

        var vowel_re = try Regex.compile(allocator, "[aeiou]+");
        defer vowel_re.deinit();
        debug.print("  '[aeiou]+' in \"hello\": {}\n", .{try vowel_re.partialMatch("hello")});

        var range_re = try Regex.compile(allocator, "[a-z]+");
        defer range_re.deinit();
        debug.print("  '[a-z]+' matches \"hello\": {}\n", .{try range_re.match("hello")});
        debug.print("  '[a-z]+' matches \"Hello\": {}\n", .{try range_re.match("Hello")});

        var neg_re = try Regex.compile(allocator, "[^0-9]+");
        defer neg_re.deinit();
        debug.print("  '[^0-9]+' matches \"abc\": {}\n\n", .{try neg_re.match("abc")});
    }

    // Example 5: Alternation
    {
        debug.print("Alternation:\n", .{});

        var alt_re = try Regex.compile(allocator, "cat|dog|bird");
        defer alt_re.deinit();
        debug.print("  'cat|dog|bird' matches \"cat\":  {}\n", .{try alt_re.match("cat")});
        debug.print("  'cat|dog|bird' matches \"dog\":  {}\n", .{try alt_re.match("dog")});
        debug.print("  'cat|dog|bird' matches \"fish\": {}\n\n", .{try alt_re.match("fish")});
    }

    // Example 6: Word boundaries
    {
        debug.print("Word Boundaries:\n", .{});

        var bound_re = try Regex.compile(allocator, "\\bword\\b");
        defer bound_re.deinit();
        debug.print("  '\\\\bword\\\\b' in \"a word here\":  {}\n", .{try bound_re.partialMatch("a word here")});
        debug.print("  '\\\\bword\\\\b' in \"a wording\":    {}\n", .{try bound_re.partialMatch("a wording")});
        debug.print("  '\\\\bword\\\\b' in \"swordfish\":    {}\n\n", .{try bound_re.partialMatch("swordfish")});
    }

    debug.print("=== Done ===\n", .{});
}
