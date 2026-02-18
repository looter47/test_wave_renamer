import Foundation

enum FileStatus: String {
    case pending
    case processing
    case done
    case skipped
    case failed
}

struct FileProcessingItem: Identifiable {
    let id = UUID()
    let originalURL: URL
    var renamedURL: URL?
    var predictedInstrument: String?
    var confidence: Float?
    var status: FileStatus = .pending
    var logMessage: String = "Queued"
}

struct InstrumentPrediction {
    let instrument: String
    let confidence: Float
}
