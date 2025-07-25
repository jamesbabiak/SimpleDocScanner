import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @AppStorage("preferredAppearance") private var preferredAppearance: String = "system"

    @State private var folderName: String = "No folder selected"
    @State private var isPresentingPicker = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("PDF Destination")) {
                    Text(folderName)
                        .font(.footnote)
                        .lineLimit(nil)
                        .padding(.vertical, 4)

                    Button("Choose Folder") {
                        isPresentingPicker = true
                    }

                    Button("Reset Folder") {
                        UserDefaults.standard.removeObject(forKey: BookmarkManager.bookmarkKey)
                        folderName = "No folder selected"
                    }
                    .foregroundColor(.red)
                }

                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $preferredAppearance) {
                        Text("System Default").tag("system")
                        Text("Light Mode").tag("light")
                        Text("Dark Mode").tag("dark")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("App Info")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    }
                    HStack {
                        Text("Credits")
                        Spacer()
                        Text("Developed by James")
                    }
                    HStack {
                        Text("App Website")
                        Spacer()
                        Link("GitHub", destination: URL(string: "https://github.com/jamesbabiak/SimpleDocScanner")!)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                updateFolderName()
            }
            .sheet(isPresented: $isPresentingPicker) {
                FolderPicker { url in
                    if let bookmark = try? url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil) {
                        UserDefaults.standard.set(bookmark, forKey: BookmarkManager.bookmarkKey)
                        folderName = BookmarkManager.displayName(for: url)
                    }
                }
            }
        }
    }

    func updateFolderName() {
        if let url = BookmarkManager.resolveBookmark() {
            folderName = BookmarkManager.displayName(for: url)
        }
    }
}

// MARK: - Folder Picker
struct FolderPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onPick: (URL) -> Void

        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}
