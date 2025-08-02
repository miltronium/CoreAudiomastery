import Foundation
import AudioToolbox

// MARK: - Core Audio Error Types

/// Comprehensive error types for Core Audio operations
public enum CoreAudioError: Error, LocalizedError {
    case fileNotFound(String)
    case unsupportedFileType(String)
    case unsupportedDataFormat(String)
    case invalidFile(String)
    case permissionDenied(String)
    case propertyNotFound(String)
    case memoryAllocation(String)
    case unknown(OSStatus, String)
    
    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let operation):
            return "Audio file not found during \(operation)"
        case .unsupportedFileType(let operation):
            return "Unsupported file type during \(operation)"
        case .unsupportedDataFormat(let operation):
            return "Unsupported data format during \(operation)"
        case .invalidFile(let operation):
            return "Invalid audio file during \(operation)"
        case .permissionDenied(let operation):
            return "Permission denied during \(operation)"
        case .propertyNotFound(let operation):
            return "Audio property not found during \(operation)"
        case .memoryAllocation(let operation):
            return "Memory allocation failed during \(operation)"
        case .unknown(let status, let operation):
            return "\(operation) failed with error: \(status.fourCharacterCode) (\(status))"
        }
    }
}

// MARK: - Result Type

/// Result type for Core Audio operations
public typealias CoreAudioResult<T> = Result<T, CoreAudioError>

// MARK: - OSStatus Extensions

extension OSStatus {
    /// Convert OSStatus to four-character code string representation
    public var fourCharacterCode: String {
        let bigEndianValue = CFSwapInt32HostToBig(UInt32(bitPattern: self))
        let bytes = withUnsafeBytes(of: bigEndianValue) { $0 }
        
        // Fix: UnicodeScalar(byte) is not optional, but we need to validate the byte value
        let characters: [Character] = bytes.compactMap { byte in
            // UnicodeScalar(byte) is not optional, but only valid for certain byte values
            // We need to check if the byte represents a valid Unicode scalar
            if byte >= 32 && byte <= 126 { // Printable ASCII range
                let scalar = UnicodeScalar(byte)
                return Character(scalar)
            } else {
                return nil
            }
        }
        
        if characters.count == 4 {
            return "'\(String(characters))'"
        } else {
            return "\(self)"
        }
    }
    
    /// Check if OSStatus indicates success
    public var isSuccess: Bool {
        return self == noErr
    }
    
    /// Throw appropriate CoreAudioError if status indicates failure
    public func throwIfError(operation: String) throws {
        guard self == noErr else {
            throw CoreAudioError.unknown(self, operation)
        }
    }
    
    /// Convert OSStatus to CoreAudioError
    public func toCoreAudioError(operation: String) -> CoreAudioError {
        // Map common OSStatus codes to specific CoreAudioError cases
        switch self {
        case kAudioFileUnsupportedFileTypeError:
            return .unsupportedFileType(operation)
        case kAudioFileUnsupportedDataFormatError:
            return .unsupportedDataFormat(operation)
        case kAudioFileInvalidFileError:
            return .invalidFile(operation)
        case kAudioFilePermissionsError:
            return .permissionDenied(operation)
        default:
            return .unknown(self, operation)
        }
    }
}

// MARK: - Character Extensions

extension Character {
    /// Check if character is printable ASCII
    var isPrintableASCII: Bool {
        guard let ascii = self.asciiValue else { return false }
        return ascii >= 32 && ascii <= 126
    }
}

// MARK: - Convenience Functions

/// Enhanced error checking function with four-character code support
public func CheckError(_ status: OSStatus, operation: String) {
    guard status == noErr else {
        print("Error in \(operation): \(status.fourCharacterCode) (\(status))")
        exit(1)
    }
}

/// Safe error checking that returns Result instead of exiting
public func SafeCheckError<T>(_ status: OSStatus, operation: String, value: T) -> CoreAudioResult<T> {
    if status == noErr {
        return .success(value)
    } else {
        return .failure(status.toCoreAudioError(operation: operation))
    }
}
