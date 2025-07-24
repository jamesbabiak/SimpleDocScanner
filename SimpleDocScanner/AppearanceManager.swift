import SwiftUI

class AppearanceManager {
    static func applyAppearance() {
        let style = UserDefaults.standard.string(forKey: "preferredAppearance") ?? "system"

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            switch style {
            case "light":
                window.overrideUserInterfaceStyle = .light
            case "dark":
                window.overrideUserInterfaceStyle = .dark
            default:
                window.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
}
