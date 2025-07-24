import SwiftUI

struct ScanPreviewView: View {
    @Binding var images: [UIImage]
    var onScanMore: () -> Void
    var onSave: (String, Bool) -> Void  // (filename, forceShare)

    @State private var showFilenamePrompt = false
    @State private var forceShare = false
    @State private var filename: String = "Scanned_\(UUID().uuidString.prefix(6)).pdf"

    var body: some View {
        NavigationView {
            VStack {
                if images.isEmpty {
                    Text("No pages scanned.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    TabView {
                        ForEach(images.indices, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: images[index])
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                                    .padding()

                                Button(action: {
                                    images.remove(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .padding(8)
                                        .background(Color.red.opacity(0.7))
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
                                        .padding([.top, .trailing], 12)
                                }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                }

                HStack(spacing: 20) {
                    Button("Scan More") {
                        onScanMore()
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                    Button("Share PDF") {
                        forceShare = true
                        showFilenamePrompt = true
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Button("Save PDF") {
                        forceShare = false
                        showFilenamePrompt = true
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .alert("File Name", isPresented: $showFilenamePrompt, actions: {
                TextField("Enter filename", text: $filename)
                Button("OK") {
                    let trimmed = filename.trimmingCharacters(in: .whitespacesAndNewlines)
                    let validName = trimmed.isEmpty ? "Scanned_\(UUID().uuidString.prefix(6)).pdf" : trimmed
                    let finalName = validName.hasSuffix(".pdf") ? validName : "\(validName).pdf"
                    onSave(finalName, forceShare)
                }
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("Name your scanned PDF file.")
            })
        }
    }
}
