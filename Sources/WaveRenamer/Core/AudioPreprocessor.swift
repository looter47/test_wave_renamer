import AVFoundation
import Foundation

struct AudioPreprocessor {
    let targetSampleRate: Double = 16_000

    func loadMonoPCMBuffer(fileURL: URL) throws -> AVAudioPCMBuffer {
        let audioFile = try AVAudioFile(forReading: fileURL)
        guard let workingFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: targetSampleRate,
            channels: 1,
            interleaved: false
        ) else {
            throw NSError(domain: "WaveRenamer", code: 1001, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create working audio format."
            ])
        }

        let frameCount = AVAudioFrameCount(audioFile.length)
        guard let sourceBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: frameCount) else {
            throw NSError(domain: "WaveRenamer", code: 1002, userInfo: [
                NSLocalizedDescriptionKey: "Failed to allocate source buffer."
            ])
        }

        try audioFile.read(into: sourceBuffer)

        let converter = AVAudioConverter(from: audioFile.processingFormat, to: workingFormat)
        guard let converter else {
            throw NSError(domain: "WaveRenamer", code: 1003, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create audio converter."
            ])
        }

        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: workingFormat, frameCapacity: frameCount) else {
            throw NSError(domain: "WaveRenamer", code: 1004, userInfo: [
                NSLocalizedDescriptionKey: "Failed to allocate output buffer."
            ])
        }

        var conversionError: NSError?
        converter.convert(to: outputBuffer, error: &conversionError) { _, status in
            status.pointee = .haveData
            return sourceBuffer
        }

        if let conversionError {
            throw conversionError
        }

        return outputBuffer
    }
}
