#!/bin/bash

# Day 6: Chapter 1 C Basic Implementation Start
# Following the study schedule

echo "📚 Starting Chapter 1: Overview of Core Audio"
echo "==========================================="
echo

# Create Chapter 1 directory structure
echo "📁 Creating Chapter 1 directory structure..."
mkdir -p ../CoreAudioMastery/Chapters/Chapter01-Overview/{Sources,Tests,Documentation,Resources}
mkdir -p ../CoreAudioMastery/Chapters/Chapter01-Overview/Sources/{C,Cpp,ObjC,Swift}/{basic,enhanced,professional}

# Create Chapter 1 README
cat > ../CoreAudioMastery/Chapters/Chapter01-Overview/README.md << 'EOF'
# Chapter 1: Overview of Core Audio

## Learning Objectives
- Understand Core Audio's property-driven API
- Work with AudioFile Services for metadata extraction
- Handle four-character codes and OSStatus errors
- Build first Core Audio application

## Implementation Progress
- [ ] C Basic Implementation
- [ ] C Enhanced Implementation  
- [ ] C Professional Implementation
- [ ] C++ Implementation
- [ ] Objective-C Implementation
- [ ] Swift Implementation

## Key Concepts
- Property-driven APIs
- AudioFileID opaque type
- OSStatus error handling
- Core Foundation memory management
EOF

echo "✅ Chapter structure created"

# Create the basic CAMetadata.c from the book
echo
echo "📝 Creating C Basic implementation (book example)..."
cat > ../CoreAudioMastery/Chapters/Chapter01-Overview/Sources/C/basic/CAMetadata.c << 'EOF'
// CAMetadata.c - Chapter 1 Example from Learning Core Audio
// Extracts and displays metadata from an audio file

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if (argc < 2) {
        printf ("Usage: CAMetadata /full/path/to/audiofile\n");
        return -1;
    }
    
    NSString *audioFilePath = [[NSString stringWithUTF8String:argv[1]]
                               stringByExpandingTildeInPath];
    
    NSURL *audioURL = [NSURL fileURLWithPath:audioFilePath];
    
    AudioFileID audioFile;
    OSStatus theErr = noErr;
    
    theErr = AudioFileOpenURL((CFURLRef)audioURL,
                             kAudioFileReadPermission,
                             0,
                             &audioFile);
    assert (theErr == noErr);
    
    UInt32 dictionarySize = 0;
    theErr = AudioFileGetPropertyInfo (audioFile,
                                      kAudioFilePropertyInfoDictionary,
                                      &dictionarySize,
                                      0);
    assert (theErr == noErr);
    
    CFDictionaryRef dictionary;
    theErr = AudioFileGetProperty (audioFile,
                                  kAudioFilePropertyInfoDictionary,
                                  &dictionarySize,
                                  &dictionary);
    assert (theErr == noErr);
    
    NSLog (@"dictionary: %@", dictionary);
    
    CFRelease (dictionary);
    
    theErr = AudioFileClose (audioFile);
    assert (theErr == noErr);
    
    [pool drain];
    return 0;
}
EOF

# Create a simple Makefile
cat > ../CoreAudioMastery/Chapters/Chapter01-Overview/Sources/C/basic/Makefile << 'EOF'
# Makefile for CAMetadata

CC = clang
CFLAGS = -Wall -framework Foundation -framework AudioToolbox
TARGET = CAMetadata

$(TARGET): CAMetadata.c
	$(CC) $(CFLAGS) -o $(TARGET) CAMetadata.c

clean:
	rm -f $(TARGET)

.PHONY: clean
EOF

echo "✅ Basic C implementation created"

# Create a test audio file path script
echo
echo "📝 Creating test helper script..."
cat > test_chapter1.sh << 'EOF'
#!/bin/bash

# Test Chapter 1 implementations

echo "🧪 Testing Chapter 1 Basic Implementation"
echo "========================================"

# Move to Chapter 1 directory
cd ../CoreAudioMastery/Chapters/Chapter01-Overview/Sources/C/basic

# Build using our ca-build system (from tutorial-scripts)
echo "🔨 Building CAMetadata..."
if ../../../../../../../tutorial-scripts/scripts/ca-build objc CAMetadata.c CAMetadata; then
    echo "✅ Build successful"
    
    # Test with a system sound
    echo
    echo "🎵 Testing with system sound..."
    if [[ -f "/System/Library/Sounds/Ping.aiff" ]]; then
        ./CAMetadata "/System/Library/Sounds/Ping.aiff"
    else
        echo "ℹ️  System sound not found. Usage:"
        echo "   ./CAMetadata /path/to/audiofile"
    fi
else
    echo "❌ Build failed"
fi
EOF

chmod +x test_chapter1.sh

echo
echo "✅ Chapter 1 setup complete!"
echo
echo "📝 Created files:"
echo "  - CoreAudioMastery/Chapters/Chapter01-Overview/README.md"
echo "  - CoreAudioMastery/Chapters/Chapter01-Overview/Sources/C/basic/CAMetadata.c"
echo "  - CoreAudioMastery/Chapters/Chapter01-Overview/Sources/C/basic/Makefile"
echo "  - test_chapter1.sh"
echo
echo "🚀 Next steps:"
echo "  1. cd ../CoreAudioMastery/Chapters/Chapter01-Overview/Sources/C/basic"
echo "  2. Build: make"
echo "  3. Test: ./CAMetadata ~/Music/somefile.mp3"
echo "  Or run: ./test_chapter1.sh"
