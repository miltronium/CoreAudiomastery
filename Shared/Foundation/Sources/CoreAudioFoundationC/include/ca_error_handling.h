// ca_error_handling.h - Professional Core Audio Error Handling
#ifndef CA_ERROR_HANDLING_H
#define CA_ERROR_HANDLING_H

#include <AudioToolbox/AudioToolbox.h>
#include <CoreFoundation/CoreFoundation.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Error handling function pointer type for custom error handlers
typedef void (*CAErrorHandler)(OSStatus error, const char* operation, const char* file, int line);

// Professional error checking - never use assert() in production
void CheckError(OSStatus error, const char* operation);
void CheckErrorWithFile(OSStatus error, const char* operation, const char* file, int line);

// Convenience macro for file/line tracking
#define CHECK_ERROR(error, operation) CheckErrorWithFile(error, operation, __FILE__, __LINE__)

// Four-character code utilities
char* FourCharCodeToString(OSStatus code);
OSStatus StringToFourCharCode(const char* string);
bool IsPrintableFourCharCode(OSStatus code);

// Error handler management
void SetCustomErrorHandler(CAErrorHandler handler);
void ResetErrorHandler(void);

// Memory-safe string utilities
void FreeFourCharString(char* string);

// Error categorization
bool IsFileError(OSStatus error);
bool IsFormatError(OSStatus error);
bool IsPropertyError(OSStatus error);

#ifdef __cplusplus
}
#endif

#endif // CA_ERROR_HANDLING_H
