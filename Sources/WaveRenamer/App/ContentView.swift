import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ProcessingViewModel
    @State private var isDropTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("WAVE Instrument Identifier")
                    .font(.title2.bold())
                Spacer()
                Button(viewModel.isProcessing ? "Processing..." : "Start") {
                    viewModel.processQueue()
                }
                .disabled(viewModel.isProcessing)
            }

            dropZone

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("Confidence threshold")
                    Slider(value: Binding(
                        get: { Double(viewModel.confidenceThreshold) },
                        set: { viewModel.confidenceThreshold = Float($0) }
                    ), in: 0.3...0.95)
                }

                VStack(alignment: .leading) {
                    Text("Naming pattern")
                    TextField("{instrument}_Track_{index}", text: $viewModel.namingPattern)
                        .textFieldStyle(.roundedBorder)
                }
            }

            ProgressView(value: viewModel.overallProgress)

            Table(viewModel.items) {
                TableColumn("Original") { item in
                    Text(item.originalURL.lastPathComponent)
                }
                TableColumn("Instrument") { item in
                    Text(item.predictedInstrument ?? "-")
                }
                TableColumn("Confidence") { item in
                    if let confidence = item.confidence {
                        Text(String(format: "%.2f", confidence))
                    } else {
                        Text("-")
                    }
                }
                TableColumn("Status") { item in
                    Text(item.status.rawValue.capitalized)
                }
                TableColumn("Log") { item in
                    Text(item.logMessage)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding(20)
    }

    private var dropZone: some View {
        RoundedRectangle(cornerRadius: 14)
            .stroke(isDropTargeted ? .blue : .gray, style: .init(lineWidth: 2, dash: [8]))
            .frame(height: 160)
            .overlay(
                VStack(spacing: 6) {
                    Image(systemName: "waveform.path.ecg.rectangle")
                        .font(.system(size: 34))
                    Text("Drop .wav files or folders")
                        .font(.headline)
                    Text("Files are processed in parallel and renamed in place")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            )
            .onDrop(of: ["public.file-url"], isTargeted: $isDropTargeted) { providers in
                Task {
                    let urls = await providers.loadFileURLs()
                    await MainActor.run {
                        let expanded = urls.flatMap(Self.expandFolders)
                        viewModel.enqueue(urls: expanded)
                    }
                }
                return true
            }
    }

    private static func expandFolders(_ url: URL) -> [URL] {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            return []
        }

        if isDirectory.boolValue {
            guard let enumerator = FileManager.default.enumerator(
                at: url,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else {
                return []
            }

            return enumerator.compactMap { $0 as? URL }
        }

        return [url]
    }
}

private extension Array where Element == NSItemProvider {
    func loadFileURLs() async -> [URL] {
        await withTaskGroup(of: URL?.self) { group in
            for provider in self {
                group.addTask {
                    await withCheckedContinuation { continuation in
                        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
                            guard
                                let data = item as? Data,
                                let url = URL(dataRepresentation: data, relativeTo: nil)
                            else {
                                continuation.resume(returning: nil)
                                return
                            }

                            continuation.resume(returning: url)
                        }
                    }
                }
            }

            var urls: [URL] = []
            for await url in group {
                if let url {
                    urls.append(url)
                }
            }
            return urls
        }
    }
}
