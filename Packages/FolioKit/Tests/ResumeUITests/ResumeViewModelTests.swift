import ResumeCore
@testable import ResumeUI
import XCTest

@MainActor
final class ResumeViewModelTests: XCTestCase {
    private struct ExportFailed: Error {}

    private func makeResume() throws -> Resume {
        try ResumeLoader.bundled()
    }

    func testFilteringByTechnologyAndClearingIt() throws {
        let model = ResumeViewModel(resume: try makeResume(), exportCV: { _ in URL(fileURLWithPath: "/tmp/cv.pdf") })
        let everything = model.visibleProjects.count

        model.toggle("UIKit")
        XCTAssertEqual(model.selectedTechnology, "UIKit")
        XCTAssertTrue(model.visibleProjects.allSatisfy { $0.technologies.contains("UIKit") })
        XCTAssertLessThan(model.visibleProjects.count, everything)

        model.toggle("UIKit")
        XCTAssertNil(model.selectedTechnology)
        XCTAssertEqual(model.visibleProjects.count, everything)
    }

    func testProjectCountText() throws {
        let one = Fixtures.resume(projects: [Fixtures.project("a", technologies: ["SwiftUI", "Metal"])])
        let model = ResumeViewModel(resume: one, exportCV: { _ in URL(fileURLWithPath: "/tmp/cv.pdf") })

        XCTAssertEqual(model.projectCountText, "1 project")
        model.toggle("Metal")
        XCTAssertEqual(model.projectCountText, "1 project with Metal")
    }

    func testTheCVIsWrittenOnce() throws {
        var exports = 0
        let model = ResumeViewModel(resume: try makeResume()) { _ in
            exports += 1
            return URL(fileURLWithPath: "/tmp/cv.pdf")
        }

        model.prepareCV()
        model.prepareCV()

        XCTAssertEqual(exports, 1)
        XCTAssertEqual(model.cvURL?.lastPathComponent, "cv.pdf")
        XCTAssertFalse(model.cvFailed)
    }

    func testAFailedExportIsReportedAndRetried() throws {
        var shouldFail = true
        let model = ResumeViewModel(resume: try makeResume()) { _ in
            if shouldFail { throw ExportFailed() }
            return URL(fileURLWithPath: "/tmp/cv.pdf")
        }

        model.prepareCV()
        XCTAssertTrue(model.cvFailed)
        XCTAssertNil(model.cvURL)

        shouldFail = false
        model.prepareCV()
        XCTAssertFalse(model.cvFailed)
        XCTAssertNotNil(model.cvURL)
    }

    func testMailGoesToTheResumeEmail() throws {
        let model = ResumeViewModel(resume: try makeResume(), exportCV: { _ in URL(fileURLWithPath: "/tmp/cv.pdf") })
        XCTAssertEqual(model.mailURL?.absoluteString.hasPrefix("mailto:poghosyanir@gmail.com?subject="), true)
    }
}

/// Small builders shared by the UI tests.
enum Fixtures {
    static func project(_ id: String, technologies: [String]) -> Project {
        Project(
            id: id, name: id, tagline: "", summary: "", highlights: [], technologies: technologies,
            repository: URL(fileURLWithPath: "/"), icon: "", screenshots: [], accent: "#000000", featured: false
        )
    }

    static func resume(projects: [Project]) -> Resume {
        Resume(
            profile: Profile(name: "Test Person", title: "iOS Developer", location: "Yerevan", availability: nil, summary: "Hi", photo: nil),
            contact: Contact(email: "a@b.com", links: []),
            skills: [], experience: [], education: [], languages: [], projects: projects
        )
    }
}
