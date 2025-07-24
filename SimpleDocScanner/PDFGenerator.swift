import UIKit
import PDFKit
import Vision

class PDFGenerator {
    static func generateSearchablePDF(from images: [UIImage], filename: String? = nil, completion: @escaping (URL?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let pdfDocument = PDFDocument()

            for (pageIndex, image) in images.enumerated() {
                guard let page = PDFPage(image: image) else { continue }
                pdfDocument.insert(page, at: pdfDocument.pageCount)

                // OCR to create invisible searchable layer
                let request = VNRecognizeTextRequest { (request, error) in
                    guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                        print("OCR error on page \(pageIndex): \(error?.localizedDescription ?? "unknown error")")
                        return
                    }

                    guard let pdfPage = pdfDocument.page(at: pageIndex) else { return }

                    for observation in observations {
                        guard let candidate = observation.topCandidates(1).first else { continue }
                        let boundingBox = observation.boundingBox

                        let bounds = pdfPage.bounds(for: .mediaBox)
                        let transform = CGAffineTransform(scaleX: bounds.width, y: bounds.height)
                        let rect = boundingBox.applying(transform)

                        let annotation = PDFAnnotation(bounds: rect, forType: .freeText, withProperties: nil)
                        annotation.contents = candidate.string
                        annotation.font = UIFont.systemFont(ofSize: 8)
                        annotation.color = .clear
                        annotation.fontColor = .clear
                        pdfPage.addAnnotation(annotation)
                    }
                }

                request.recognitionLevel = .accurate
                request.usesLanguageCorrection = true

                guard let cgImage = image.cgImage else { continue }
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                try? handler.perform([request])
            }

            // Save PDF to a temporary file
            let finalFilename = (filename?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
                ? filename!
                : "ScannedDocument_\(UUID().uuidString.prefix(6))"

            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(finalFilename).pdf")

            if pdfDocument.write(to: tempURL) {
                DispatchQueue.main.async {
                    completion(tempURL)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
