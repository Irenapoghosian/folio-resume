import ResumeCore
@testable import ResumeUI
import SwiftUI
import XCTest

final class FlowLayoutTests: XCTestCase {
    private let chip = CGSize(width: 40, height: 20)

    func testItemsWrapWhenTheRowIsFull() {
        let frames = FlowLayout.frames(for: [chip, chip, chip], maxWidth: 100, spacing: 10)

        XCTAssertEqual(frames.map(\.origin), [CGPoint(x: 0, y: 0), CGPoint(x: 50, y: 0), CGPoint(x: 0, y: 30)])
    }

    func testAnItemWiderThanTheRowGetsALineOfItsOwn() {
        let wide = CGSize(width: 300, height: 24)
        let frames = FlowLayout.frames(for: [wide, chip], maxWidth: 100, spacing: 8)

        XCTAssertEqual(frames[0].origin, .zero)
        XCTAssertEqual(frames[1].origin, CGPoint(x: 0, y: 32))
    }

    func testRowsAreAsTallAsTheirTallestItem() {
        let tall = CGSize(width: 40, height: 50)
        let frames = FlowLayout.frames(for: [chip, tall, chip], maxWidth: 90, spacing: 0)

        XCTAssertEqual(frames[2].origin, CGPoint(x: 0, y: 50))
        XCTAssertEqual(FlowLayout.frames(for: [], maxWidth: 100, spacing: 8), [])
    }
}

final class ThemeTests: XCTestCase {
    func testAppearances() {
        XCTAssertNil(Appearance.system.colorScheme)
        XCTAssertEqual(Appearance.light.colorScheme, .light)
        XCTAssertEqual(Appearance.dark.colorScheme, .dark)
        XCTAssertEqual(Appearance(rawValue: "dark"), .dark)
        XCTAssertEqual(Set(Appearance.allCases.map(\.symbolName)).count, 3)
    }

    func testEveryLinkKindHasASymbol() {
        let kinds: [ContactLink.Kind] = [.upwork, .linkedin, .github, .website]
        XCTAssertEqual(Set(kinds.map(\.symbolName)).count, kinds.count)
    }
}

@MainActor
final class CVExporterTests: XCTestCase {
    func testTheCVIsAOnePagePDF() throws {
        let data = CVExporter.pdfData(for: try ResumeLoader.bundled())

        XCTAssertEqual(String(bytes: data.prefix(5), encoding: .ascii), "%PDF-")
        XCTAssertGreaterThan(data.count, 2_000)
        let provider = try XCTUnwrap(CGDataProvider(data: data as CFData))
        let document = try XCTUnwrap(CGPDFDocument(provider))
        XCTAssertEqual(document.numberOfPages, 1)
        let page = try XCTUnwrap(document.page(at: 1))
        XCTAssertEqual(page.getBoxRect(.mediaBox).size, CVExporter.pageSize)
    }

    func testTheCVIsNamedAfterThePerson() throws {
        let url = try CVExporter.writePDF(for: Fixtures.resume(projects: []))
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertEqual(url.lastPathComponent, "Test-Person-CV.pdf")
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }
}
