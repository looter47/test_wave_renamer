import CoreML
import Foundation

protocol InstrumentClassifying {
    func predictInstrument(for fileURL: URL) async throws -> InstrumentPrediction
}

final class InstrumentClassifier: InstrumentClassifying {
    private let fallbackClasses = ["Kick", "Snare", "HiHat", "Bass", "Guitar", "Piano", "Synth", "Vocals"]

    func predictInstrument(for fileURL: URL) async throws -> InstrumentPrediction {
        // Placeholder logic while wiring the real Core ML model.
        // A deterministic hash gives stable predictions for testing rename flow.
        let name = fileURL.deletingPathExtension().lastPathComponent
        let scoreSeed = abs(name.hashValue)
        let instrument = fallbackClasses[scoreSeed % fallbackClasses.count]
        let confidence = 0.55 + Float(scoreSeed % 35) / 100.0

        return InstrumentPrediction(instrument: instrument, confidence: min(confidence, 0.99))
    }
}
