// ca_property_helpers.h - Safe Core Audio Property Access
#ifndef CA_PROPERTY_HELPERS_H
#define CA_PROPERTY_HELPERS_H

#include <AudioToolbox/AudioToolbox.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Safe property access with automatic memory management
OSStatus GetAudioFileProperty(AudioFileID audioFile, 
                             AudioFilePropertyID propertyID,
                             UInt32* ioDataSize, 
                             void* outPropertyData);

OSStatus GetAudioFilePropertyInfo(AudioFileID audioFile,
                                 AudioFilePropertyID propertyID,
                                 UInt32* outDataSize,
                                 UInt32* isWritable);

// Type-safe property getters for common types
OSStatus GetAudioFileStringProperty(AudioFileID audioFile,
                                   AudioFilePropertyID propertyID,
                                   CFStringRef* outString);

OSStatus GetAudioFileNumberProperty(AudioFileID audioFile,
                                   AudioFilePropertyID propertyID,
                                   CFNumberRef* outNumber);

OSStatus GetAudioFileDictionaryProperty(AudioFileID audioFile,
                                       AudioFilePropertyID propertyID,
                                       CFDictionaryRef* outDictionary);

// Property validation
bool IsPropertySupported(AudioFileID audioFile, AudioFilePropertyID propertyID);
bool IsPropertyWritable(AudioFileID audioFile, AudioFilePropertyID propertyID);

// Memory-managed property access
typedef struct {
    void* data;
    UInt32 size;
    AudioFilePropertyID propertyID;
} CAPropertyData;

CAPropertyData* CreatePropertyData(AudioFileID audioFile, AudioFilePropertyID propertyID);
void FreePropertyData(CAPropertyData* propertyData);

#ifdef __cplusplus
}
#endif

#endif // CA_PROPERTY_HELPERS_H
