import ResumeCore
import SwiftUI

/// Turns the résumé into a one-page A4 PDF, drawn by SwiftUI (`CVDocumentView`) with `ImageRenderer`.
@MainActor
public enum CVExporter {
    /// A4 in PDF points.
    public static let pageSize = CGSize(width: 595, height: 842)

    public static func pdfData(for resume: Resume) -> Data {
        let page = CVDocumentView(resume: resume)
            .frame(width: pageSize.width, height: pageSize.height)
        let renderer = ImageRenderer(content: page)
        let data = NSMutableData()
        renderer.render { _, draw in
            var box = CGRect(origin: .zero, size: pageSize)
            guard
                let consumer = CGDataConsumer(data: data as CFMutableData),
                let context = CGContext(consumer: consumer, mediaBox: &box, nil)
            else { return }
            context.beginPDFPage(nil)
            draw(context)
            context.endPDFPage()
            context.closePDF()
        }
        return data as Data
    }

    /// Writes "Irina-Poghosyan-CV.pdf" to the temporary folder, ready for the share sheet.
    public static func writePDF(for resume: Resume) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(ResumeRules.cvFileName(for: resume.profile.name))
        try pdfData(for: resume).write(to: url, options: .atomic)
        return url
    }
}
