#!/bin/bash

# Day 1 - Step 3: Automated Environment Setup with COMPLETE Build Scripts
# Core Audio Tutorial - Setup and Foundation

set -e

echo "[$(date '+%H:%M:%S')] [DAY 1 - STEP 3] Automated Environment Setup"
echo "=================================================================="

# Source environment file - simple approach
if [[ -f "../.core-audio-env" ]]; then
    echo "[$(date '+%H:%M:%S')] 📍 Found environment file: ../.core-audio-env"
    source "../.core-audio-env"
elif [[ -f ".core-audio-env" ]]; then
    echo "[$(date '+%H:%M:%S')] 📍 Found environment file: .core-audio-env"
    source ".core-audio-env"
elif [[ -f "$HOME/Development/CoreAudio/.core-audio-env" ]]; then
    echo "[$(date '+%H:%M:%S')] 📍 Found environment file: $HOME/Development/CoreAudio/.core-audio-env"
    source "$HOME/Development/CoreAudio/.core-audio-env"
else
    echo "[$(date '+%H:%M:%S')] ❌ Environment file not found. Run step01 first."
    exit 1
fi

# Function to log with timestamp and Day 1 session tracking
log_action() {
    echo "[$(date '+%H:%M:%S')] $1"
    if [[ -n "$LOGS_DIR" && -d "$LOGS_DIR" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAY1-STEP3] $1" >> "$LOGS_DIR/day01_session.log"
    fi
}

# Now continue with main execution
log_action "🎯 Starting automated environment setup for Day 1"

# Validate prerequisites
if [[ -z "$TUTORIAL_ROOT" ]]; then
    log_action "❌ TUTORIAL_ROOT not set. Environment sourcing failed."
    exit 1
fi

log_action "✅ Environment variables loaded successfully"
log_action "📁 TUTORIAL_ROOT: $TUTORIAL_ROOT"

cd "$TUTORIAL_ROOT"

# Simple Xcode check
log_action "🔍 Checking Xcode tools"
if command -v clang > /dev/null 2>&1; then
    log_action "✅ Clang compiler available"
else
    log_action "❌ Xcode command line tools not found. Run: xcode-select --install"
    exit 1
fi

# Test Core Audio framework
log_action "🎵 Testing Core Audio framework"
if echo "#include <AudioToolbox/AudioToolbox.h>" | clang -framework AudioToolbox -x c -c - -o /dev/null 2>/dev/null; then
    log_action "✅ Core Audio framework accessible"
else
    log_action "❌ Core Audio framework not accessible"
    exit 1
fi

# Create environment activation script
log_action "📝 Creating environment activation script"
cat > activate-ca-env.sh << 'ACTIVATE_SCRIPT'
#!/bin/bash
# Core Audio Tutorial Environment Activation
if [[ -f "../.core-audio-env" ]]; then
    source "../.core-audio-env"
elif [[ -f ".core-audio-env" ]]; then
    source ".core-audio-env"
fi
validate_environment() {
    echo "🔍 Validating Core Audio environment..."
    if [[ -d "$CORE_AUDIO_ROOT" && -d "$TUTORIAL_ROOT" ]]; then
        echo "✓ Repository paths valid"
    else
        echo "✗ Repository paths invalid"
        return 1
    fi
    if echo "#include <AudioToolbox/AudioToolbox.h>" | clang -framework AudioToolbox -x c -c - -o /dev/null 2>/dev/null; then
        echo "✓ Core Audio framework accessible"
    else
        echo "✗ Core Audio framework not accessible"
        return 1
    fi
    echo "Environment validation passed ✓"
    return 0
}
echo "Core Audio Tutorial Environment Activated"
echo "Tutorial Root: $TUTORIAL_ROOT"
ACTIVATE_SCRIPT

chmod +x activate-ca-env.sh
log_action "✅ Environment activation script created"

# Create build scripts directory
log_action "🔧 Creating complete build scripts directory"
mkdir -p scripts

# =====================================================================
# COMPLETE BUILD SCRIPTS CREATION - ALL LANGUAGES
# =====================================================================

log_action "🔨 Creating C build script"
cat > scripts/build-c.sh << 'BUILD_C_SCRIPT'
#!/bin/bash
# Complete C Build Script for Core Audio Tutorial
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <source.c> [output_name] [additional_flags]"
    echo "Example: $0 metadata_extractor.c metadata_tool"
    echo "Example: $0 test_audio.c test_tool -DDEBUG"
    exit 1
fi

source_file="$1"
output_name="${2:-$(basename "$source_file" .c)}"
additional_flags="${3:-}"

echo "🔨 Building C program: $source_file"
echo "📦 Output: $output_name"

# Check if source file exists
if [[ ! -f "$source_file" ]]; then
    echo "❌ Source file not found: $source_file"
    exit 1
fi

# Build with Core Audio frameworks
clang -framework AudioToolbox -framework Foundation \
      -Wall -Wextra -std=c99 \
      $additional_flags \
      "$source_file" -o "$output_name"

if [[ $? -eq 0 ]]; then
    echo "✅ Successfully built: $output_name"
    echo "🚀 Run with: ./$output_name"
else
    echo "❌ Build failed"
    exit 1
fi
BUILD_C_SCRIPT

chmod +x scripts/build-c.sh

log_action "🔨 Creating C++ build script"
cat > scripts/build-cpp.sh << 'BUILD_CPP_SCRIPT'
#!/bin/bash
# Complete C++ Build Script for Core Audio Tutorial
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <source.cpp> [output_name] [additional_flags]"
    echo "Example: $0 audio_processor.cpp audio_tool"
    echo "Example: $0 metadata_service.cpp service -std=c++17"
    exit 1
fi

source_file="$1"
output_name="${2:-$(basename "$source_file" .cpp)}"
additional_flags="${3:-}"

echo "🔨 Building C++ program: $source_file"
echo "📦 Output: $output_name"

# Check if source file exists
if [[ ! -f "$source_file" ]]; then
    echo "❌ Source file not found: $source_file"
    exit 1
fi

# Build with Core Audio frameworks and modern C++
clang++ -framework AudioToolbox -framework Foundation \
        -std=c++14 -Wall -Wextra \
        -stdlib=libc++ \
        $additional_flags \
        "$source_file" -o "$output_name"

if [[ $? -eq 0 ]]; then
    echo "✅ Successfully built: $output_name"
    echo "🚀 Run with: ./$output_name"
else
    echo "❌ Build failed"
    exit 1
fi
BUILD_CPP_SCRIPT

chmod +x scripts/build-cpp.sh

log_action "🔨 Creating Objective-C build script"
cat > scripts/build-objc.sh << 'BUILD_OBJC_SCRIPT'
#!/bin/bash
# Complete Objective-C Build Script for Core Audio Tutorial
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <source.m> [output_name] [additional_frameworks]"
    echo "Example: $0 metadata_manager.m metadata_app"
    echo "Example: $0 audio_service.m service '-framework CloudKit'"
    exit 1
fi

source_file="$1"
output_name="${2:-$(basename "$source_file" .m)}"
additional_frameworks="${3:-}"

echo "🔨 Building Objective-C program: $source_file"
echo "📦 Output: $output_name"

# Check if source file exists
if [[ ! -f "$source_file" ]]; then
    echo "❌ Source file not found: $source_file"
    exit 1
fi

# Build with Core Audio and Foundation frameworks
clang -framework AudioToolbox -framework Foundation -framework Cocoa \
      -fobjc-arc -Wall -Wextra \
      $additional_frameworks \
      "$source_file" -o "$output_name"

if [[ $? -eq 0 ]]; then
    echo "✅ Successfully built: $output_name"
    echo "🚀 Run with: ./$output_name"
else
    echo "❌ Build failed"
    exit 1
fi
BUILD_OBJC_SCRIPT

chmod +x scripts/build-objc.sh

log_action "🔨 Creating Swift build script"
cat > scripts/build-swift.sh << 'BUILD_SWIFT_SCRIPT'
#!/bin/bash
# Complete Swift Build Script for Core Audio Tutorial
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <source.swift> [output_name] [swift_flags]"
    echo "Example: $0 metadata_tool.swift metadata_app"
    echo "Example: $0 audio_processor.swift processor '-O'"
    exit 1
fi

source_file="$1"
output_name="${2:-$(basename "$source_file" .swift)}"
swift_flags="${3:-}"

echo "🔨 Building Swift program: $source_file"
echo "📦 Output: $output_name"

# Check if source file exists
if [[ ! -f "$source_file" ]]; then
    echo "❌ Source file not found: $source_file"
    exit 1
fi

# Build with Swift compiler
swiftc -framework AudioToolbox -framework Foundation \
       -import-objc-header /System/Library/Frameworks/AudioToolbox.framework/Headers/AudioToolbox.h \
       $swift_flags \
       "$source_file" -o "$output_name"

if [[ $? -eq 0 ]]; then
    echo "✅ Successfully built: $output_name"
    echo "🚀 Run with: ./$output_name"
else
    echo "❌ Build failed"
    exit 1
fi
BUILD_SWIFT_SCRIPT

chmod +x scripts/build-swift.sh

log_action "🔨 Creating CMake configuration script"
cat > scripts/setup-cmake.sh << 'CMAKE_SCRIPT'
#!/bin/bash
# CMake Setup Script for C/C++ Projects
set -e

echo "🔧 Setting up CMake build system"

# Create CMakeLists.txt template
cat > CMakeLists.txt << 'CMAKE_TEMPLATE'
cmake_minimum_required(VERSION 3.16)
project(CoreAudioProject)

# Set C++ standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required frameworks
find_library(AUDIO_TOOLBOX AudioToolbox)
find_library(FOUNDATION Foundation)

if(NOT AUDIO_TOOLBOX)
    message(FATAL_ERROR "AudioToolbox framework not found")
endif()

if(NOT FOUNDATION)
    message(FATAL_ERROR "Foundation framework not found")
endif()

# Compiler flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra")

# Add executable function
function(add_core_audio_executable target_name source_file)
    add_executable(${target_name} ${source_file})
    target_link_libraries(${target_name} ${AUDIO_TOOLBOX} ${FOUNDATION})
endfunction()

# Example usage (uncomment and modify as needed):
# add_core_audio_executable(metadata_tool metadata_extractor.c)
CMAKE_TEMPLATE

echo "✅ CMakeLists.txt template created"
echo "📝 To use:"
echo "   1. Modify CMakeLists.txt to add your executables"
echo "   2. mkdir build && cd build"
echo "   3. cmake .."
echo "   4. make"
CMAKE_SCRIPT

chmod +x scripts/setup-cmake.sh

log_action "🔨 Creating Xcode project generation script"
cat > scripts/create-xcode-project.sh << 'XCODE_SCRIPT'
#!/bin/bash
# Xcode Project Creation Script for Core Audio Tutorial
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <project_name> [template_type]"
    echo "Templates: c, cpp, objc, swift"
    echo "Example: $0 MetadataExtractor objc"
    exit 1
fi

project_name="$1"
template_type="${2:-c}"

echo "🔨 Creating Xcode project: $project_name"
echo "📝 Template type: $template_type"

# Create project directory
mkdir -p "$project_name"
cd "$project_name"

# Create basic Xcode project structure based on template
case "$template_type" in
    "c")
        echo "Creating C project template..."
        cat > main.c << 'C_TEMPLATE'
#include <stdio.h>
#include <AudioToolbox/AudioToolbox.h>

int main(int argc, const char * argv[]) {
    printf("Core Audio C Project\n");
    
    // Add your Core Audio code here
    
    return 0;
}
C_TEMPLATE
        ;;
    "cpp")
        echo "Creating C++ project template..."
        cat > main.cpp << 'CPP_TEMPLATE'
#include <iostream>
#include <AudioToolbox/AudioToolbox.h>

int main(int argc, const char * argv[]) {
    std::cout << "Core Audio C++ Project" << std::endl;
    
    // Add your Core Audio code here
    
    return 0;
}
CPP_TEMPLATE
        ;;
    "objc")
        echo "Creating Objective-C project template..."
        cat > main.m << 'OBJC_TEMPLATE'
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"Core Audio Objective-C Project");
        
        // Add your Core Audio code here
        
    }
    return 0;
}
OBJC_TEMPLATE
        ;;
    "swift")
        echo "Creating Swift project template..."
        cat > main.swift << 'SWIFT_TEMPLATE'
import Foundation
import AudioToolbox

print("Core Audio Swift Project")

// Add your Core Audio code here
SWIFT_TEMPLATE
        ;;
    *)
        echo "❌ Unknown template type: $template_type"
        exit 1
        ;;
esac

# Create build script
cat > build.sh << 'BUILD_TEMPLATE'
#!/bin/bash
set -e

echo "🔨 Building project..."

case "TEMPLATE_TYPE" in
    "c")
        clang -framework AudioToolbox -framework Foundation main.c -o PROJECT_NAME
        ;;
    "cpp")
        clang++ -framework AudioToolbox -framework Foundation -std=c++14 main.cpp -o PROJECT_NAME
        ;;
    "objc")
        clang -framework AudioToolbox -framework Foundation -fobjc-arc main.m -o PROJECT_NAME
        ;;
    "swift")
        swiftc -framework AudioToolbox -framework Foundation main.swift -o PROJECT_NAME
        ;;
esac

echo "✅ Build complete: ./PROJECT_NAME"
BUILD_TEMPLATE

# Replace placeholders in build script
sed -i '' "s/PROJECT_NAME/$project_name/g" build.sh
sed -i '' "s/TEMPLATE_TYPE/$template_type/g" build.sh
chmod +x build.sh

echo "✅ Xcode project created: $project_name"
echo "📁 Project directory: $(pwd)"
echo "🚀 Build with: ./build.sh"

cd ..
XCODE_SCRIPT

chmod +x scripts/create-xcode-project.sh

log_action "🔨 Creating validation script for build scripts"
cat > scripts/validate-build-scripts.sh << 'VALIDATE_SCRIPT'
#!/bin/bash
# Validation Script for All Build Scripts
set -e

echo "🔍 Validating all build scripts..."

SCRIPTS_DIR="$(dirname "$0")"
BUILD_SCRIPTS=(
    "build-c.sh"
    "build-cpp.sh"
    "build-objc.sh"
    "build-swift.sh"
    "setup-cmake.sh"
    "create-xcode-project.sh"
)

ALL_VALID=true

for script in "${BUILD_SCRIPTS[@]}"; do
    script_path="$SCRIPTS_DIR/$script"
    if [[ -f "$script_path" && -x "$script_path" ]]; then
        echo "✅ $script - found and executable"
    else
        echo "❌ $script - missing or not executable"
        ALL_VALID=false
    fi
done

if $ALL_VALID; then
    echo "🎉 All build scripts validated successfully!"
    echo
    echo "📋 Available build scripts:"
    echo "  🔨 build-c.sh - Build C programs"
    echo "  🔨 build-cpp.sh - Build C++ programs"
    echo "  🔨 build-objc.sh - Build Objective-C programs"
    echo "  🔨 build-swift.sh - Build Swift programs"
    echo "  🔧 setup-cmake.sh - Create CMake configuration"
    echo "  📱 create-xcode-project.sh - Generate Xcode projects"
    echo
    echo "🚀 Usage examples:"
    echo "  scripts/build-c.sh my_program.c"
    echo "  scripts/build-swift.sh metadata_tool.swift"
    echo "  scripts/create-xcode-project.sh MyApp objc"
else
    echo "❌ Build script validation failed!"
    exit 1
fi
VALIDATE_SCRIPT

chmod +x scripts/validate-build-scripts.sh

log_action "✅ All build scripts created successfully"

# Test environment
log_action "🧪 Testing environment"
source activate-ca-env.sh
if validate_environment; then
    log_action "✅ Environment test successful"
else
    log_action "❌ Environment test failed"
    exit 1
fi

# Validate build scripts
log_action "🔍 Validating build scripts"
if scripts/validate-build-scripts.sh; then
    log_action "✅ Build scripts validation successful"
else
    log_action "❌ Build scripts validation failed"
    exit 1
fi

log_action "🎯 Day 1 - Step 3 Complete: Environment setup with complete build scripts!"
echo "📝 To complete Day 1: ./step04_install_frameworks.sh"
