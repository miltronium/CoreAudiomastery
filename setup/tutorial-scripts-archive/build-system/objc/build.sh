#!/bin/bash

# Objective-C Build Script for Core Audio
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <source.m> [output_name]"
    exit 1
fi

SOURCE_FILE="$1"
OUTPUT_NAME="${2:-$(basename "$SOURCE_FILE" .m)}"

echo "🔨 Building Objective-C program: $SOURCE_FILE"

# Compile with Core Audio frameworks
clang -Wall -Wextra -fobjc-arc \
    -framework AudioToolbox \
    -framework CoreFoundation \
    -framework Foundation \
    "$SOURCE_FILE" \
    -o "$OUTPUT_NAME"

echo "✅ Built: $OUTPUT_NAME"
