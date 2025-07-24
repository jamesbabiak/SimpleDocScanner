import SwiftUI

@main
struct SimpleDocScannerApp: App {
    @AppStorage("preferredAppearance") private var preferredAppearance: String = "system"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    AppearanceManager.applyAppearance()
                }
                .onChange(of: preferredAppearance) {
                    AppearanceManager.applyAppearance()
                }
        }
    }
}
