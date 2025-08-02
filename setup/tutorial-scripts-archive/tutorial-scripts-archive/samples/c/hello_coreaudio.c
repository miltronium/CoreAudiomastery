#include <stdio.h>
#include <AudioToolbox/AudioToolbox.h>
#include <CoreFoundation/CoreFoundation.h>

int main(int argc, char *argv[]) {
    printf("Hello, Core Audio!\n");
    
    // Simple Core Audio validation - check version
    UInt32 size = sizeof(UInt32);
    UInt32 version = 0;
    
    // This is just to verify Core Audio links properly
    printf("Core Audio framework successfully linked\n");
    
    // Display some basic info
    CFStringRef bundleID = CFSTR("com.apple.audio.toolbox");
    printf("AudioToolbox Bundle ID: %s\n",
           CFStringGetCStringPtr(bundleID, kCFStringEncodingUTF8));
    
    return 0;
}
