#include <stdio.h>
#include <AudioToolbox/AudioToolbox.h>
#include <CoreFoundation/CoreFoundation.h>

int main(void) {
    printf("Hello, Core Audio!\n");
    printf("Core Audio framework successfully linked\n");
    printf("AudioToolbox is ready for use!\n");
    
    if (AudioFileOpenURL != NULL) {
        printf("AudioFile API is available\n");
    }
    
    return 0;
}
