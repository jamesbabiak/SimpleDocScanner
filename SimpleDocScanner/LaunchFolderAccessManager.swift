import SwiftUI
import UniformTypeIdentifiers

class LaunchFolderAccessManager: ObservableObject {
    @Published var showPermissionAlert: Bool = false
    @Published var showFolderPicker: Bool = false

    func checkFolderAccessOnLaunch() {
        // Only check if bookmark data exists at all
        guard let bookmarkData = UserDefaults.standard.data(forKey: BookmarkManager.bookmarkKey) else {
            return // nothing to check — no folder set
        }

        // Attempt to resolve it and test access
        var isStale = false
        guard let url = try? URL(resolvingBookmarkData: bookmarkData, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale), !isStale else {
            showPermissionAlert = true
            return
        }

        _ = url.startAccessingSecurityScopedResource()

        let testFile = url.appendingPathComponent("access_test.tmp")
        do {
            try "test".write(to: testFile, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(at: testFile)
        } catch {
            print("📛 Cannot access saved folder: \(error)")
            showPermissionAlert = true
        }
    }
}
