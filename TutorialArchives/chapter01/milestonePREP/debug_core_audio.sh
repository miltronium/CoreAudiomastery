#!/bin/bash

# Debug Core Audio Framework Compilation Issue
# Quick diagnostic script

echo "🔍 Core Audio Framework Debug"
echo "============================"

# Check basic tools
echo "1. Checking development tools:"
echo -n "  clang: "
if command -v clang > /dev/null; then
    echo "✅ $(clang --version | head -1)"
else
    echo "❌ Not found"
fi

echo -n "  Xcode tools: "
if xcode-select --print-path > /dev/null 2>&1; then
    echo "✅ $(xcode-select --print-path)"
else
    echo "❌ Not found"
fi

# Check framework paths
echo
echo "2. Checking AudioToolbox framework:"
FRAMEWORK_PATHS=(
    "/System/Library/Frameworks/AudioToolbox.framework"
    "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/AudioToolbox.framework"
    "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/AudioToolbox.framework"
)

for path in "${FRAMEWORK_PATHS[@]}"; do
    if [[ -d "$path" ]]; then
        echo "  ✅ Found: $path"
    else
        echo "  ❌ Not found: $path"
    fi
done

# Create minimal test file
echo
echo "3. Creating minimal test file:"
TEST_FILE="/tmp/ca_debug_test.c"
cat > "$TEST_FILE" << 'TEST_EOF'
#include <AudioToolbox/AudioToolbox.h>
#include <stdio.h>

int main() {
    printf("Test successful\n");
    return 0;
}
TEST_EOF

echo "  ✅ Created: $TEST_FILE"

# Try different compilation approaches
echo
echo "4. Testing compilation approaches:"

echo -n "  Basic AudioToolbox: "
if clang -framework AudioToolbox "$TEST_FILE" -o /tmp/ca_test 2>/dev/null; then
    echo "✅ Success"
    rm -f /tmp/ca_test
else
    echo "❌ Failed"
    echo "     Error output:"
    clang -framework AudioToolbox "$TEST_FILE" -o /tmp/ca_test 2>&1 | head -3 | sed 's/^/     /'
fi

echo -n "  With Foundation: "
if clang -framework AudioToolbox -framework Foundation "$TEST_FILE" -o /tmp/ca_test 2>/dev/null; then
    echo "✅ Success"
    rm -f /tmp/ca_test
else
    echo "❌ Failed"
    echo "     Error output:"
    clang -framework AudioToolbox -framework Foundation "$TEST_FILE" -o /tmp/ca_test 2>&1 | head -3 | sed 's/^/     /'
fi

echo -n "  With explicit SDK: "
SDK_PATH=$(xcrun --show-sdk-path 2>/dev/null)
if [[ -n "$SDK_PATH" ]]; then
    if clang -isysroot "$SDK_PATH" -framework AudioToolbox "$TEST_FILE" -o /tmp/ca_test 2>/dev/null; then
        echo "✅ Success"
        rm -f /tmp/ca_test
    else
        echo "❌ Failed"
        echo "     Error output:"
        clang -isysroot "$SDK_PATH" -framework AudioToolbox "$TEST_FILE" -o /tmp/ca_test 2>&1 | head -3 | sed 's/^/     /'
    fi
else
    echo "❌ No SDK path found"
fi

# Check what verification script is actually doing
echo
echo "5. Checking verification script test:"
VERIFY_TEST_FILE="/tmp/test_ca_$$.c"
if [[ -f "$VERIFY_TEST_FILE" ]]; then
    echo "  Found existing verification test file: $VERIFY_TEST_FILE"
    echo "  Contents:"
    cat "$VERIFY_TEST_FILE" | head -10 | sed 's/^/    /'
else
    echo "  No existing verification test file found"
fi

# Cleanup
rm -f "$TEST_FILE" /tmp/ca_test

echo
echo "6. Recommendations:"
if ! command -v clang > /dev/null; then
    echo "  ❌ Install Xcode command line tools: xcode-select --install"
elif ! xcode-select --print-path > /dev/null 2>&1; then
    echo "  ❌ Install Xcode command line tools: xcode-select --install"
elif ! ls /System/Library/Frameworks/AudioToolbox.framework > /dev/null 2>&1 && \
     ! ls /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/AudioToolbox.framework > /dev/null 2>&1; then
    echo "  ❌ AudioToolbox framework not found - check Xcode installation"
else
    echo "  ✅ Basic setup looks correct - issue may be in verification script"
fi

echo
echo "Debug complete. If basic compilation works but verification fails,"
echo "the issue is likely in the verification script's test setup."
