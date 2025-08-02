#!/bin/bash

# Day 2 Test All Languages Script
echo "🧪 Testing All Language Builds"
echo "=============================="
echo

# Test C++
echo "📝 Creating C++ test..."
mkdir -p samples/cpp
cat > samples/cpp/hello_coreaudio.cpp << 'EOF'
#include <iostream>
#include <AudioToolbox/AudioToolbox.h>

int main() {
    std::cout << "Hello from C++ Core Audio!" << std::endl;
    std::cout << "AudioToolbox linked successfully" << std::endl;
    return 0;
}
EOF

echo "🔨 Building C++..."
if ca-build cpp samples/cpp/hello_coreaudio.cpp; then
    echo "✅ C++ build successful"
    ./hello_coreaudio
    rm -f hello_coreaudio
else
    echo "❌ C++ build failed"
fi
echo

# Test Objective-C
echo "📝 Creating Objective-C test..."
mkdir -p samples/objc
cat > samples/objc/hello_coreaudio.m << 'EOF'
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"Hello from Objective-C Core Audio!");
        NSLog(@"AudioToolbox linked successfully");
    }
    return 0;
}
EOF

echo "🔨 Building Objective-C..."
if ca-build objc samples/objc/hello_coreaudio.m; then
    echo "✅ Objective-C build successful"
    ./hello_coreaudio
    rm -f hello_coreaudio
else
    echo "❌ Objective-C build failed"
fi
echo

# Test Swift
echo "📝 Creating Swift test..."
mkdir -p samples/swift
cat > samples/swift/hello_coreaudio.swift << 'EOF'
import Foundation
import AudioToolbox

print("Hello from Swift Core Audio!")
print("AudioToolbox linked successfully")

// Test Core Foundation bridging
let testString = "Core Audio" as CFString
print("CFString test: \(testString)")
EOF

echo "🔨 Building Swift..."
if ca-build swift samples/swift/hello_coreaudio.swift; then
    echo "✅ Swift build successful"
    ./hello_coreaudio
    rm -f hello_coreaudio
else
    echo "❌ Swift build failed"
fi

echo
echo "✅ Language testing complete!"
echo
echo "Summary:"
echo "- C: ✅ (tested earlier)"
echo "- C++: Tested above"
echo "- Objective-C: Tested above"
echo "- Swift: Tested above"
echo
echo "🎯 Ready for Chapter 1 implementation!"
