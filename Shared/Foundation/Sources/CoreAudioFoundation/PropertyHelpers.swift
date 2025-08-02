import Foundation
import AudioToolbox

// MARK: - Property Support Functions

/// Check if property is supported
public func IsPropertySupported(_ audioFile: AudioFileID, _ propertyID: AudioFilePropertyID) -> Bool {
    var dataSize: UInt32 = 0
    let status = AudioFileGetPropertyInfo(audioFile, propertyID, &dataSize, nil)
    return status == noErr
}

/// Check if property is writable
public func IsPropertyWritable(_ audioFile: AudioFileID, _ propertyID: AudioFilePropertyID) -> Bool {
    var dataSize: UInt32 = 0
    var isWritable: UInt32 = 0
    let status = AudioFileGetPropertyInfo(audioFile, propertyID, &dataSize, &isWritable)
    return status == noErr && isWritable != 0
}

// MARK: - AudioFileID Extensions

extension AudioFileID {
    /// Get dictionary property with Result type
    public func getDictionaryProperty(_ propertyID: AudioFilePropertyID) -> CoreAudioResult<CFDictionary> {
        var dataSize: UInt32 = 0
        var status = AudioFileGetPropertyInfo(self, propertyID, &dataSize, nil)
        
        guard status == noErr else {
            return .failure(status.toCoreAudioError(operation: "getDictionaryProperty"))
        }
        
        guard dataSize > 0 else {
            return .failure(.propertyNotFound("getDictionaryProperty"))
        }
        
        var dictionary: Unmanaged<CFDictionary>?
        status = AudioFileGetProperty(self, propertyID, &dataSize, &dictionary)
        
        guard status == noErr else {
            return .failure(status.toCoreAudioError(operation: "getDictionaryProperty"))
        }
        
        guard let dict = dictionary?.takeRetainedValue() else {
            return .failure(.propertyNotFound("getDictionaryProperty"))
        }
        
        return .success(dict)
    }
    
    /// Get string property with Result type
    public func getStringProperty(_ propertyID: AudioFilePropertyID) -> CoreAudioResult<CFString> {
        var dataSize: UInt32 = 0
        var status = AudioFileGetPropertyInfo(self, propertyID, &dataSize, nil)
        
        guard status == noErr else {
            return .failure(status.toCoreAudioError(operation: "getStringProperty"))
        }
        
        guard dataSize > 0 else {
            return .failure(.propertyNotFound("getStringProperty"))
        }
        
        var string: Unmanaged<CFString>?
        status = AudioFileGetProperty(self, propertyID, &dataSize, &string)
        
        guard status == noErr else {
            return .failure(status.toCoreAudioError(operation: "getStringProperty"))
        }
        
        guard let str = string?.takeRetainedValue() else {
            return .failure(.propertyNotFound("getStringProperty"))
        }
        
        return .success(str)
    }
    
    /// Get number property with Result type
    public func getNumberProperty(_ propertyID: AudioFilePropertyID) -> CoreAudioResult<CFNumber> {
        var dataSize: UInt32 = 0
        var status = AudioFileGetPropertyInfo(self, propertyID, &dataSize, nil)
        
        guard status == noErr else {
            return .failure(status.toCoreAudioError(operation: "getNumberProperty"))
        }
        
        guard dataSize > 0 else {
            return .failure(.propertyNotFound("getNumberProperty"))
        }
        
        var number: Unmanaged<CFNumber>?
        status = AudioFileGetProperty(self, propertyID, &dataSize, &number)
        
        guard status == noErr else {
            return .failure(status.toCoreAudioError(operation: "getNumberProperty"))
        }
        
        guard let num = number?.takeRetainedValue() else {
            return .failure(.propertyNotFound("getNumberProperty"))
        }
        
        return .success(num)
    }
    
    /// Get generic property with type safety
    public func getProperty<T>(_ propertyID: AudioFilePropertyID, type: T.Type) -> CoreAudioResult<T> {
        var dataSize: UInt32 = 0
        var status = AudioFileGetPropertyInfo(self, propertyID, &dataSize, nil)
        
        guard status == noErr else {
            return .failure(status.toCoreAudioError(operation: "getProperty"))
        }
        
        let expectedSize = UInt32(MemoryLayout<T>.size)
        guard dataSize == expectedSize else {
            return .failure(.unknown(-1, "Property size mismatch"))
        }
        
        let buffer = UnsafeMutablePointer<T>.allocate(capacity: 1)
        defer { buffer.deallocate() }
        
        var actualSize = dataSize
        status = AudioFileGetProperty(self, propertyID, &actualSize, buffer)
        
        guard status == noErr else {
            return .failure(status.toCoreAudioError(operation: "getProperty"))
        }
        
        return .success(buffer.pointee)
    }
    
    /// Check if property is supported
    public func isPropertySupported(_ propertyID: AudioFilePropertyID) -> Bool {
        return IsPropertySupported(self, propertyID)
    }
    
    /// Check if property is writable
    public func isPropertyWritable(_ propertyID: AudioFilePropertyID) -> Bool {
        return IsPropertyWritable(self, propertyID)
    }
}
