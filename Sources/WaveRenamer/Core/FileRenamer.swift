import Foundation

struct FileRenamer {
    func rename(
        fileURL: URL,
        instrument: String,
        pattern: String = "{instrument}_Track_{index}",
        fileManager: FileManager = .default
    ) throws -> URL {
        let directory = fileURL.deletingLastPathComponent()
        let ext = fileURL.pathExtension

        var index = 1
        while index <= 9_999 {
            let padded = String(format: "%02d", index)
            let base = pattern
                .replacingOccurrences(of: "{instrument}", with: sanitize(instrument))
                .replacingOccurrences(of: "{index}", with: padded)

            let targetURL = directory.appendingPathComponent(base).appendingPathExtension(ext)
            if !fileManager.fileExists(atPath: targetURL.path) {
                try fileManager.moveItem(at: fileURL, to: targetURL)
                return targetURL
            }

            index += 1
        }

        throw NSError(domain: "WaveRenamer", code: 3001, userInfo: [
            NSLocalizedDescriptionKey: "Unable to find an available filename for \(fileURL.lastPathComponent)."
        ])
    }

    private func sanitize(_ instrument: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(.init(charactersIn: "-_"))
        return instrument
            .components(separatedBy: allowed.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "_")
    }
}
