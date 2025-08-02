import Foundation
import AudioToolbox

// MARK: - Audio Format Utilities

/// Utility functions for working with Core Audio formats and format descriptions

public struct AudioFormatUtilities {
    
    /// Convert AudioStreamBasicDescription to human-readable string
    public static func descriptionString(for asbd: AudioStreamBasicDescription) -> String {
        let formatID = OSStatus(asbd.mFormatID).fourCharacterCode
        let formatFlags = String(format: "0x%X", asbd.mFormatFlags)
        
        return """
        Audio Format Description:
          Format ID: \(formatID)
          Sample Rate: \(asbd.mSampleRate) Hz
          Format Flags: \(formatFlags)
          Bytes Per Packet: \(asbd.mBytesPerPacket)
          Frames Per Packet: \(asbd.mFramesPerPacket)
          Bytes Per Frame: \(asbd.mBytesPerFrame)
          Channels Per Frame: \(asbd.mChannelsPerFrame)
          Bits Per Channel: \(asbd.mBitsPerChannel)
        """
    }
    
    /// Check if format is PCM
    public static func isPCM(_ asbd: AudioStreamBasicDescription) -> Bool {
        return asbd.mFormatID == kAudioFormatLinearPCM
    }
    
    /// Check if format is interleaved
    public static func isInterleaved(_ asbd: AudioStreamBasicDescription) -> Bool {
        return (asbd.mFormatFlags & kAudioFormatFlagIsNonInterleaved) == 0
    }
    
    /// Check if format is floating point
    public static func isFloat(_ asbd: AudioStreamBasicDescription) -> Bool {
        return (asbd.mFormatFlags & kAudioFormatFlagIsFloat) != 0
    }
    
    /// Calculate bytes per sample for PCM format
    public static func bytesPerSample(for asbd: AudioStreamBasicDescription) -> UInt32? {
        guard isPCM(asbd) else { return nil }
        return asbd.mBitsPerChannel / 8
    }
}

// MARK: - UInt32 Extension (Format ID conversion only, reusing OSStatus implementation)

extension UInt32 {
    /// Convert format ID to four-character code string (delegates to OSStatus)
    public var fourCharacterCode: String {
        return OSStatus(self).fourCharacterCode
    }
}

// MARK: - AudioStreamBasicDescription Extensions

extension AudioStreamBasicDescription {
    /// Get description string
    public var description: String {
        return AudioFormatUtilities.descriptionString(for: self)
    }
    
    /// Check if format is PCM
    public var isPCM: Bool {
        return AudioFormatUtilities.isPCM(self)
    }
    
    /// Check if format is interleaved
    public var isInterleaved: Bool {
        return AudioFormatUtilities.isInterleaved(self)
    }
    
    /// Check if format is floating point
    public var isFloat: Bool {
        return AudioFormatUtilities.isFloat(self)
    }
    
    /// Get bytes per sample (for PCM formats)
    public var bytesPerSample: UInt32? {
        return AudioFormatUtilities.bytesPerSample(for: self)
    }
}

// MARK: - Common Format Creators

extension AudioStreamBasicDescription {
    /// Create standard PCM format
    public static func standardPCMFormat(sampleRate: Double, channels: UInt32, bitsPerChannel: UInt32) -> AudioStreamBasicDescription {
        let bytesPerSample = bitsPerChannel / 8
        
        return AudioStreamBasicDescription(
            mSampleRate: sampleRate,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
            mBytesPerPacket: bytesPerSample * channels,
            mFramesPerPacket: 1,
            mBytesPerFrame: bytesPerSample * channels,
            mChannelsPerFrame: channels,
            mBitsPerChannel: bitsPerChannel,
            mReserved: 0
        )
    }
    
    /// Create standard floating point format
    public static func standardFloatFormat(sampleRate: Double, channels: UInt32) -> AudioStreamBasicDescription {
        return AudioStreamBasicDescription(
            mSampleRate: sampleRate,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked,
            mBytesPerPacket: 4 * channels,
            mFramesPerPacket: 1,
            mBytesPerFrame: 4 * channels,
            mChannelsPerFrame: channels,
            mBitsPerChannel: 32,
            mReserved: 0
        )
    }
}
