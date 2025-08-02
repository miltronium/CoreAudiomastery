#include "ca_property_helpers.h"
#include "ca_error_handling.h"
#include <stdlib.h>
#include <string.h>

// Safe property access with comprehensive error checking
OSStatus GetAudioFileProperty(AudioFileID audioFile,
                             AudioFilePropertyID propertyID,
                             UInt32* ioDataSize,
                             void* outPropertyData) {
    // Validate parameters
    if (!audioFile || !ioDataSize || !outPropertyData) {
        return kAudioFileInvalidFileError;
    }
    
    // Check if property is supported
    if (!IsPropertySupported(audioFile, propertyID)) {
        return kAudioFileUnsupportedPropertyError;
    }
    
    // Get the property with error handling
    OSStatus result = AudioFileGetProperty(audioFile, propertyID, ioDataSize, outPropertyData);
    if (result != noErr) {
        CHECK_ERROR(result, "AudioFileGetProperty");
    }
    
    return result;
}

OSStatus GetAudioFilePropertyInfo(AudioFileID audioFile,
                                 AudioFilePropertyID propertyID,
                                 UInt32* outDataSize,
                                 UInt32* isWritable) {
    // Validate parameters
    if (!audioFile || !outDataSize) {
        return kAudioFileInvalidFileError;
    }
    
    OSStatus result = AudioFileGetPropertyInfo(audioFile, propertyID, outDataSize, isWritable);
    if (result != noErr) {
        CHECK_ERROR(result, "AudioFileGetPropertyInfo");
    }
    
    return result;
}

// Type-safe string property getter
OSStatus GetAudioFileStringProperty(AudioFileID audioFile,
                                   AudioFilePropertyID propertyID,
                                   CFStringRef* outString) {
    if (!outString) return kAudioFileInvalidFileError;
    
    UInt32 dataSize = 0;
    OSStatus result = GetAudioFilePropertyInfo(audioFile, propertyID, &dataSize, NULL);
    if (result != noErr) return result;
    
    if (dataSize == 0) {
        *outString = NULL;
        return noErr;
    }
    
    CFStringRef string = NULL;
    result = GetAudioFileProperty(audioFile, propertyID, &dataSize, &string);
    if (result == noErr) {
        *outString = string;
    }
    
    return result;
}

// Type-safe number property getter  
OSStatus GetAudioFileNumberProperty(AudioFileID audioFile,
                                   AudioFilePropertyID propertyID,
                                   CFNumberRef* outNumber) {
    if (!outNumber) return kAudioFileInvalidFileError;
    
    UInt32 dataSize = 0;
    OSStatus result = GetAudioFilePropertyInfo(audioFile, propertyID, &dataSize, NULL);
    if (result != noErr) return result;
    
    if (dataSize == 0) {
        *outNumber = NULL;
        return noErr;
    }
    
    CFNumberRef number = NULL;
    result = GetAudioFileProperty(audioFile, propertyID, &dataSize, &number);
    if (result == noErr) {
        *outNumber = number;
    }
    
    return result;
}

// Type-safe dictionary property getter
OSStatus GetAudioFileDictionaryProperty(AudioFileID audioFile,
                                       AudioFilePropertyID propertyID,
                                       CFDictionaryRef* outDictionary) {
    if (!outDictionary) return kAudioFileInvalidFileError;
    
    UInt32 dataSize = 0;
    OSStatus result = GetAudioFilePropertyInfo(audioFile, propertyID, &dataSize, NULL);
    if (result != noErr) return result;
    
    if (dataSize == 0) {
        *outDictionary = NULL;
        return noErr;
    }
    
    CFDictionaryRef dictionary = NULL;
    result = GetAudioFileProperty(audioFile, propertyID, &dataSize, &dictionary);
    if (result == noErr) {
        *outDictionary = dictionary;
    }
    
    return result;
}

// Property validation functions
bool IsPropertySupported(AudioFileID audioFile, AudioFilePropertyID propertyID) {
    UInt32 dataSize = 0;
    OSStatus result = AudioFileGetPropertyInfo(audioFile, propertyID, &dataSize, NULL);
    return (result == noErr);
}

bool IsPropertyWritable(AudioFileID audioFile, AudioFilePropertyID propertyID) {
    UInt32 dataSize = 0;
    UInt32 isWritable = 0;
    OSStatus result = AudioFileGetPropertyInfo(audioFile, propertyID, &dataSize, &isWritable);
    return (result == noErr && isWritable != 0);
}

// Memory-managed property access
CAPropertyData* CreatePropertyData(AudioFileID audioFile, AudioFilePropertyID propertyID) {
    // Allocate property data structure
    CAPropertyData* propertyData = malloc(sizeof(CAPropertyData));
    if (!propertyData) return NULL;
    
    // Initialize structure
    propertyData->data = NULL;
    propertyData->size = 0;
    propertyData->propertyID = propertyID;
    
    // Get property size
    OSStatus result = GetAudioFilePropertyInfo(audioFile, propertyID, &propertyData->size, NULL);
    if (result != noErr || propertyData->size == 0) {
        free(propertyData);
        return NULL;
    }
    
    // Allocate data buffer
    propertyData->data = malloc(propertyData->size);
    if (!propertyData->data) {
        free(propertyData);
        return NULL;
    }
    
    // Get property data
    result = GetAudioFileProperty(audioFile, propertyID, &propertyData->size, propertyData->data);
    if (result != noErr) {
        free(propertyData->data);
        free(propertyData);
        return NULL;
    }
    
    return propertyData;
}

void FreePropertyData(CAPropertyData* propertyData) {
    if (propertyData) {
        if (propertyData->data) {
            free(propertyData->data);
        }
        free(propertyData);
    }
}
