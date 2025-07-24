import SwiftUI
import VisionKit
import PDFKit

struct ContentView: View {
    @State private var showScanner = false
    @State private var showSettings = false
    @State private var showPreview = false
    @State private var showShareSheet = false
    @State private var showSuccessAlert = false
    @State private var isGeneratingPDF = false
    @State private var scannedImages: [UIImage] = []
    @State private var scannedPageCount: Int?
    @State private var generatedPDFURL: URL?

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    Image("AppIconImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding(.top)

                    Text("DocSnap")
                        .font(.largeTitle)
                        .bold()

                    Button(action: {
                        scannedImages = []
                        showScanner = true
                    }) {
                        Text("Scan Document")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        showSettings = true
                    }) {
                        Text("Settings")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    if let count = scannedPageCount {
                        Text("Scanned \(count) page(s)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }

                if isGeneratingPDF {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView("Generating PDF…")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showScanner) {
            scannerSheet
        }
        .sheet(isPresented: $showPreview) {
            ScanPreviewView(
                images: $scannedImages,
                onScanMore: {
                    showPreview = false
                    showScanner = true
                },
                onSave: { filename, share in
                    scannedPageCount = scannedImages.count
                    showPreview = false
                    generatePDF(named: filename, forceShare: share)
                }
            )
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = generatedPDFURL {
                ShareSheet(activityItems: [url])
            } else {
                Text("Failed to create PDF.")
            }
        }
        .alert(isPresented: $showSuccessAlert) {
            Alert(title: Text("Success"), message: Text("PDF saved successfully."), dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Scanner Sheet
    @ViewBuilder
    var scannerSheet: some View {
        #if targetEnvironment(simulator)
        Text("Document scanning is only available on a real device.")
            .padding()
        #else
        DocumentScannerView { images in
            scannedImages.append(contentsOf: images)
            showScanner = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showPreview = true
            }
        }
        #endif
    }

    // MARK: - PDF Generation
    func generatePDF(named filename: String, forceShare: Bool = false) {
        isGeneratingPDF = true

        PDFGenerator.generateSearchablePDF(from: scannedImages, filename: filename) { tempURL in
            isGeneratingPDF = false

            guard let tempURL = tempURL else {
                print("❌ Failed to generate PDF")
                return
            }

            if forceShare {
                generatedPDFURL = tempURL
                showShareSheet = true
                return
            }

            if let targetFolder = BookmarkManager.resolveBookmark() {
                let finalURL = targetFolder.appendingPathComponent("\(filename).pdf")

                do {
                    try FileManager.default.copyItem(at: tempURL, to: finalURL)
                    print("✅ PDF saved to folder: \(finalURL)")
                    showSuccessAlert = true
                } catch {
                    print("❌ Failed to save to folder: \(error.localizedDescription)")
                    generatedPDFURL = tempURL
                    showShareSheet = true
                }
            } else {
                print("📤 No folder set — using share sheet.")
                generatedPDFURL = tempURL
                showShareSheet = true
            }
        }
    }
}
