#include <stdio.h>
#include <stdbool.h>
#include "regex.h"

// Example: Input validation using regex patterns

typedef struct {
    const char* name;
    const char* pattern;
    zre_regex* compiled;
} Validator;

bool validate(Validator* v, const char* input) {
    return zre_match(v->compiled, input);
}

int main() {
    // Define validation patterns
    Validator validators[] = {
        // Username: 3-16 alphanumeric chars, underscores allowed
        {"Username", "^[a-zA-Z0-9_]{3,16}$", NULL},
        
        // Password: at least 8 chars
        {"Password (8+ chars)", "^.{8,}$", NULL},
        
        // Phone: US format like 555-123-4567
        {"US Phone", "^[0-9]{3}[-.\\s]?[0-9]{3}[-.\\s]?[0-9]{4}$", NULL},
        
        // Hex color: #RRGGBB (6 digits only for simplicity)
        {"Hex Color", "^#[0-9a-fA-F]{6}$", NULL},
        
        // IPv4 address (simplified)
        {"IPv4 Address", "^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", NULL},
        
        // Time: 24-hour format HH:MM
        {"Time (24h)", "^[0-2][0-9]:[0-5][0-9]$", NULL},
    };
    
    size_t num_validators = sizeof(validators) / sizeof(validators[0]);
    
    // Compile all patterns
    printf("Compiling validation patterns...\n\n");
    for (size_t i = 0; i < num_validators; i++) {
        validators[i].compiled = zre_compile(validators[i].pattern);
        if (!validators[i].compiled) {
            printf("Failed to compile: %s\n", validators[i].name);
            return 1;
        }
    }
    
    // Test cases
    typedef struct {
        size_t validator_idx;
        const char* input;
        bool expected;
    } TestCase;
    
    TestCase tests[] = {
        // Username tests
        {0, "john_doe", true},
        {0, "ab", false},           // too short
        {0, "user@name", false},    // invalid char
        {0, "valid_user_123", true},
        
        // Password tests
        {1, "short", false},
        {1, "longenough123", true},
        {1, "12345678", true},
        
        // Phone tests
        {2, "555-123-4567", true},
        {2, "555 123 4567", true},
        {2, "5551234567", true},
        {2, "555.123.4567", true},
        {2, "123-456", false},
        
        // Hex color tests
        {3, "#FF5733", true},
        {3, "#aabbcc", true},
        {3, "#gggggg", false},
        {3, "FF5733", false},       // missing #
        
        // IPv4 tests
        {4, "192.168.1.1", true},
        {4, "10.0.0.255", true},
        {4, "192.168.1", false},
        
        // Time tests
        {5, "09:30", true},
        {5, "23:59", true},
        {5, "24:00", false},
        {5, "9:30", false},         // needs leading zero
    };
    
    size_t num_tests = sizeof(tests) / sizeof(tests[0]);
    size_t passed = 0;
    
    printf("Running validation tests:\n");
    printf("%-20s %-20s %-10s %-10s\n", "Validator", "Input", "Expected", "Result");
    printf("------------------------------------------------------------\n");
    
    for (size_t i = 0; i < num_tests; i++) {
        TestCase* t = &tests[i];
        Validator* v = &validators[t->validator_idx];
        bool result = validate(v, t->input);
        bool success = (result == t->expected);
        
        printf("%-20s %-20s %-10s %-10s %s\n",
               v->name,
               t->input,
               t->expected ? "valid" : "invalid",
               result ? "valid" : "invalid",
               success ? "[OK]" : "[FAIL]");
        
        if (success) passed++;
    }
    
    printf("\n%zu/%zu tests passed\n", passed, num_tests);
    
    // Cleanup
    for (size_t i = 0; i < num_validators; i++) {
        zre_deinit(validators[i].compiled);
    }
    
    return (passed == num_tests) ? 0 : 1;
}
