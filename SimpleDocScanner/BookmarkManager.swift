import Foundation

class BookmarkManager {
    static let bookmarkKey = "savedFolderBookmark"

    static func resolveBookmark() -> URL? {
        guard let data = UserDefaults.standard.data(forKey: bookmarkKey) else { return nil }

        var isStale = false

        // Do NOT use withSecurityScope in Xcode 16 / iOS 18+
        guard let url = try? URL(resolvingBookmarkData: data, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale), !isStale else {
            return nil
        }

        _ = url.startAccessingSecurityScopedResource()
        return url
    }
}
