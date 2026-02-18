import Foundation

@MainActor
final class ProcessingViewModel: ObservableObject {
    @Published var items: [FileProcessingItem] = []
    @Published var isProcessing = false
    @Published var overallProgress: Double = 0
    @Published var confidenceThreshold: Float = 0.5
    @Published var namingPattern = "{instrument}_Track_{index}"

    private let processor = BatchProcessor()

    func enqueue(urls: [URL]) {
        let accepted = urls.filter { $0.pathExtension.lowercased() == "wav" }
        items.append(contentsOf: accepted.map { FileProcessingItem(originalURL: $0) })
    }

    func processQueue() {
        guard !isProcessing else { return }
        let pendingIndices = items.indices.filter { items[$0].status == .pending }
        guard !pendingIndices.isEmpty else { return }

        isProcessing = true
        overallProgress = 0

        Task {
            await withTaskGroup(of: Void.self) { group in
                for index in pendingIndices {
                    group.addTask { [weak self] in
                        await self?.processSingleItem(at: index, total: pendingIndices.count)
                    }
                }
            }

            isProcessing = false
        }
    }

    private func processSingleItem(at index: Int, total: Int) async {
        guard items.indices.contains(index) else { return }
        items[index].status = .processing
        items[index].logMessage = "Analyzing"

        do {
            let result = try await processor.process(
                fileURL: items[index].originalURL,
                confidenceThreshold: confidenceThreshold,
                namingPattern: namingPattern
            )

            items[index].predictedInstrument = result.prediction.instrument
            items[index].confidence = result.prediction.confidence

            if let renamedURL = result.renamedURL {
                items[index].renamedURL = renamedURL
                items[index].status = .done
                items[index].logMessage = "Renamed → \(renamedURL.lastPathComponent)"
            } else {
                items[index].status = .skipped
                items[index].logMessage = "Low confidence (\(String(format: "%.2f", result.prediction.confidence)))"
            }
        } catch {
            items[index].status = .failed
            items[index].logMessage = error.localizedDescription
        }

        let completed = items.filter { [.done, .skipped, .failed].contains($0.status) }.count
        overallProgress = Double(completed) / Double(total)
    }
}
