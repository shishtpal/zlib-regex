#include <stdio.h>
#include <string.h>
#include "regex.h"

// Example: Extracting capture groups from regex matches

int main() {
    const char* input = "Contact: john.doe@example.com, Phone: 555-1234";
    
    // Pattern to capture email parts: (username)@(domain)
    zre_regex* email_re = zre_compile("([a-zA-Z0-9.]+)@([a-zA-Z0-9.]+)");
    if (!email_re) {
        printf("Failed to compile email regex\n");
        return 1;
    }
    
    printf("Input: %s\n\n", input);
    
    // Get all captures
    zre_captures* caps = zre_captures_all(email_re, input);
    if (caps) {
        printf("Email pattern matched!\n");
        printf("Number of capture groups: %zu\n\n", zre_captures_len(caps));
        
        // Capture 0 is always the full match
        size_t len;
        const char* full_match = zre_captures_slice_at(caps, 0, &len);
        if (full_match) {
            printf("Full match: %.*s\n", (int)len, full_match);
        }
        
        // Capture 1 is the username
        const char* username = zre_captures_slice_at(caps, 1, &len);
        if (username) {
            printf("Username:   %.*s\n", (int)len, username);
        }
        
        // Capture 2 is the domain
        const char* domain = zre_captures_slice_at(caps, 2, &len);
        if (domain) {
            printf("Domain:     %.*s\n", (int)len, domain);
        }
        
        // Get bounds (character positions) instead of slices
        printf("\nCapture bounds:\n");
        for (size_t i = 0; i < zre_captures_len(caps); i++) {
            zre_captures_span span;
            if (zre_captures_bounds_at(caps, &span, i)) {
                printf("  Group %zu: [%zu, %zu)\n", i, span.lower, span.upper);
            }
        }
        
        zre_captures_deinit(caps);
    } else {
        printf("No email found\n");
    }
    
    zre_deinit(email_re);
    
    // Another example: Parse a date string
    printf("\n--- Date Parsing Example ---\n");
    
    zre_regex* date_re = zre_compile("([0-9]{4})-([0-9]{2})-([0-9]{2})");
    if (!date_re) {
        printf("Failed to compile date regex\n");
        return 1;
    }
    
    const char* date_input = "Event scheduled for 2024-12-25 at noon";
    printf("Input: %s\n\n", date_input);
    
    caps = zre_captures_all(date_re, date_input);
    if (caps) {
        size_t len;
        const char* year = zre_captures_slice_at(caps, 1, &len);
        printf("Year:  %.*s\n", (int)len, year);
        
        const char* month = zre_captures_slice_at(caps, 2, &len);
        printf("Month: %.*s\n", (int)len, month);
        
        const char* day = zre_captures_slice_at(caps, 3, &len);
        printf("Day:   %.*s\n", (int)len, day);
        
        zre_captures_deinit(caps);
    }
    
    zre_deinit(date_re);
    
    return 0;
}
