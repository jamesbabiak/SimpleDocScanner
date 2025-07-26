import SwiftUI

@main
struct SimpleDocScannerApp: App {
    @AppStorage("preferredAppearance") private var preferredAppearance: String = "system"
    @StateObject private var folderAccessManager = LaunchFolderAccessManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(folderAccessManager)
                .onAppear {
                    AppearanceManager.applyAppearance()
                    folderAccessManager.checkFolderAccessOnLaunch()
                }
                .onChange(of: preferredAppearance) {
                    AppearanceManager.applyAppearance()
                }
        }
    }
}
