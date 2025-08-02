#include "ca_error_handling.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

// Global error handler - defaults to standard handler
static CAErrorHandler g_errorHandler = NULL;

// Standard error handler implementation
static void StandardErrorHandler(OSStatus error, const char* operation, const char* file, int line) {
    char* errorString = FourCharCodeToString(error);
    fprintf(stderr, "Core Audio Error in %s: %s (%d) at %s:%d\n", 
            operation, errorString, (int)error, file, line);
    FreeFourCharString(errorString);
}

// Professional error checking - configurable behavior
void CheckError(OSStatus error, const char* operation) {
    CheckErrorWithFile(error, operation, "unknown", 0);
}

void CheckErrorWithFile(OSStatus error, const char* operation, const char* file, int line) {
    if (error == noErr) return;
    
    // Use custom handler if set, otherwise use standard
    if (g_errorHandler) {
        g_errorHandler(error, operation, file, line);
    } else {
        StandardErrorHandler(error, operation, file, line);
    }
}

// Convert four-character code to readable string
char* FourCharCodeToString(OSStatus code) {
    // Handle special case of noErr
    if (code == noErr) {
        char* result = malloc(8);
        if (result) strcpy(result, "noErr");
        return result;
    }
    
    // Convert to big-endian for character extraction
    UInt32 bigEndianCode = CFSwapInt32HostToBig((UInt32)code);
    char codeChars[5];
    memcpy(codeChars, &bigEndianCode, 4);
    codeChars[4] = '\0';
    
    // Check if all characters are printable
    bool isPrintable = true;
    for (int i = 0; i < 4; i++) {
        if (!isprint(codeChars[i])) {
            isPrintable = false;
            break;
        }
    }
    
    char* result;
    if (isPrintable) {
        result = malloc(7);
        if (result) {
            snprintf(result, 7, "'%s'", codeChars);
        }
    } else {
        result = malloc(12);
        if (result) {
            snprintf(result, 12, "%d", (int)code);
        }
    }
    
    return result;
}

// Convert string to four-character code
OSStatus StringToFourCharCode(const char* string) {
    if (!string || strlen(string) != 4) {
        return kAudioFileUnsupportedDataFormatError;
    }
    
    // Pack four characters into 32-bit value
    UInt32 code = ((UInt32)string[0] << 24) |
                  ((UInt32)string[1] << 16) |
                  ((UInt32)string[2] << 8)  |
                  ((UInt32)string[3]);
                  
    return (OSStatus)code;
}

// Check if four-character code is printable
bool IsPrintableFourCharCode(OSStatus code) {
    UInt32 bigEndianCode = CFSwapInt32HostToBig((UInt32)code);
    char codeChars[4];
    memcpy(codeChars, &bigEndianCode, 4);
    
    for (int i = 0; i < 4; i++) {
        if (!isprint(codeChars[i])) {
            return false;
        }
    }
    return true;
}

// Error handler management
void SetCustomErrorHandler(CAErrorHandler handler) {
    g_errorHandler = handler;
}

void ResetErrorHandler(void) {
    g_errorHandler = NULL;
}

// Memory management for strings
void FreeFourCharString(char* string) {
    if (string) {
        free(string);
    }
}

// Error categorization helpers
bool IsFileError(OSStatus error) {
    return (error == kAudioFileUnsupportedFileTypeError ||
            error == kAudioFileUnsupportedDataFormatError ||
            error == kAudioFileInvalidFileError ||
            error == kAudioFilePermissionsError ||
            error == kAudio_FileNotFoundError);
}

bool IsFormatError(OSStatus error) {
    return (error == kAudioFormatUnsupportedPropertyError ||
            error == kAudioFormatUnsupportedDataFormatError ||
            error == kAudioFormatUnknownFormatError);
}

bool IsPropertyError(OSStatus error) {
    return (error == kAudioUnitErr_InvalidProperty ||
            error == kAudioUnitErr_InvalidPropertyValue ||
            error == kAudioUnitErr_PropertyNotWritable ||
            error == kAudioUnitErr_PropertyNotInUse);
}
