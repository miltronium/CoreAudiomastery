#!/bin/bash

# C Test Runner using Unity framework
set -e

TEST_DIR="${1:-.}"
echo "🧪 Running C tests in: $TEST_DIR"

# Check for Unity framework
UNITY_DIR="$TUTORIAL_ROOT/shared-frameworks/unity/src"
if [[ ! -f "$UNITY_DIR/unity.h" ]]; then
    echo "❌ Unity framework not found. Run setup scripts first."
    exit 1
fi

# Find and run test files
find "$TEST_DIR" -name "*_test.c" -o -name "test_*.c" | while read test_file; do
    echo "Running: $test_file"
    output_name="/tmp/$(basename "$test_file" .c)"
    
    # Compile test
    clang -I"$UNITY_DIR" \
        -framework AudioToolbox \
        -framework CoreFoundation \
        "$UNITY_DIR/unity.c" \
        "$test_file" \
        -o "$output_name"
    
    # Run test
    "$output_name"
    rm "$output_name"
done

echo "✅ C tests complete"
