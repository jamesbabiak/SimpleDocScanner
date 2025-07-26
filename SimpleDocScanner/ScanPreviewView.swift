import SwiftUI

struct ScanPreviewView: View {
    @Binding var images: [UIImage]
    var onScanMore: () -> Void
    var onSave: (String, Bool) -> Void  // (filename, forceShare)

    @State private var showFilenamePrompt = false
    @State private var forceShare = false
    @State private var filename: String = "Scanned_\(UUID().uuidString.prefix(6))"

    @State private var draggedImage: UIImage?

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationView {
            VStack {
                if images.isEmpty {
                    Text("No pages scanned.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(images.indices, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: images[index])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: UIScreen.main.bounds.height / 3.5)
                                        .cornerRadius(8)
                                        .padding(4)
                                        .overlay(
                                            Text("\(index + 1)")
                                                .font(.caption2)
                                                .padding(6)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                                .foregroundColor(.white)
                                                .padding(6),
                                            alignment: .topLeading
                                        )
                                        .onDrag {
                                            self.draggedImage = images[index]
                                            return NSItemProvider(object: "\(index)" as NSString)
                                        }
                                        .onDrop(of: [.text], delegate: ImageDropDelegate(
                                            item: images[index],
                                            images: $images,
                                            draggedImage: $draggedImage
                                        ))

                                    Button(action: {
                                        images.remove(at: index)
                                    }) {
                                        Image(systemName: "trash")
                                            .padding(6)
                                            .background(Color.red.opacity(0.7))
                                            .clipShape(Circle())
                                            .foregroundColor(.white)
                                            .padding(6)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
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

                    Button("Save  PDF") {
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
            .padding(.top)
            .alert("File Name", isPresented: $showFilenamePrompt, actions: {
                TextField("Enter filename", text: $filename)
                Button("OK") {
                    let trimmed = filename.trimmingCharacters(in: .whitespacesAndNewlines)
                    let validName = trimmed.isEmpty ? "Scanned_\(UUID().uuidString.prefix(6))" : trimmed
                    onSave(validName, forceShare)
                }
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("Name your scanned PDF file.")
            })
        }
    }
}
