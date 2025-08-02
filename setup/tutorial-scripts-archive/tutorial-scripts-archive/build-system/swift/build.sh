#!/bin/bash

# Swift Build Script for Core Audio
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <source.swift> [output_name]"
    exit 1
fi

SOURCE_FILE="$1"
OUTPUT_NAME="${2:-$(basename "$SOURCE_FILE" .swift)}"

echo "🔨 Building Swift program: $SOURCE_FILE"

# Compile with Core Audio frameworks
swiftc "$SOURCE_FILE" \
    -framework AudioToolbox \
    -framework CoreFoundation \
    -framework Foundation \
    -o "$OUTPUT_NAME"

echo "✅ Built: $OUTPUT_NAME"
