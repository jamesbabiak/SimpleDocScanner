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

    static func displayName(for url: URL) -> String {
        let components = url.pathComponents
        if components.count >= 2 {
            let parent = components[components.count - 2]
            let folder = components.last!
            // If parent looks like a UUID, omit it
            if parent.range(of: #"^[A-Fa-f0-9\-]{36}$"#, options: .regularExpression) != nil {
                return folder
            } else {
                return "\(parent) > \(folder)"
            }
        } else {
            return url.lastPathComponent
        }
    }
}
