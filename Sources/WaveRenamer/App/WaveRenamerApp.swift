import SwiftUI

@main
struct WaveRenamerApp: App {
    @StateObject private var viewModel = ProcessingViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 980, minHeight: 680)
        }
    }
}
