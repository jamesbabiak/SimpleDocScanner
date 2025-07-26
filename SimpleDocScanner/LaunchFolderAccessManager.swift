import SwiftUI
import UniformTypeIdentifiers

class LaunchFolderAccessManager: ObservableObject {
    @Published var showPermissionAlert: Bool = false
    @Published var showFolderPicker: Bool = false
    @Published var folderDisplayName: String = ""

    func checkFolderAccessOnLaunch() {
        guard let bookmarkData = UserDefaults.standard.data(forKey: BookmarkManager.bookmarkKey) else {
            return
        }

        var isStale = false
        guard let url = try? URL(resolvingBookmarkData: bookmarkData, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale), !isStale else {
            return
        }

        _ = url.startAccessingSecurityScopedResource()
        folderDisplayName = BookmarkManager.displayName(for: url)

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
