import Foundation

actor BatchProcessor {
    private let classifier: InstrumentClassifying
    private let fileRenamer = FileRenamer()

    init(classifier: InstrumentClassifying = InstrumentClassifier()) {
        self.classifier = classifier
    }

    func process(
        fileURL: URL,
        confidenceThreshold: Float,
        namingPattern: String
    ) async throws -> (prediction: InstrumentPrediction, renamedURL: URL?) {
        let prediction = try await classifier.predictInstrument(for: fileURL)

        guard prediction.confidence >= confidenceThreshold else {
            return (prediction, nil)
        }

        let renamedURL = try fileRenamer.rename(
            fileURL: fileURL,
            instrument: prediction.instrument,
            pattern: namingPattern
        )

        return (prediction, renamedURL)
    }
}
