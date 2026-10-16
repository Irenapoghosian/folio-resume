import ResumeCore
import XCTest

final class ResumeRulesTests: XCTestCase {
    func testPeriods() {
        XCTAssertEqual(ResumeRules.period(start: 2024, end: nil), "2024 – Present")
        XCTAssertEqual(ResumeRules.period(start: 2021, end: 2022), "2021 – 2022")
        XCTAssertEqual(ResumeRules.period(start: 2024, end: 2024), "2024")
    }

    func testPeriodsWithMonths() {
        XCTAssertEqual(ResumeRules.period(start: 2023, end: nil, startMonth: 2), "Feb 2023 – Present")
        XCTAssertEqual(ResumeRules.period(start: 2021, end: 2022, startMonth: 8), "Aug 2021 – 2022")
        XCTAssertEqual(ResumeRules.period(start: 2021, end: 2021, startMonth: 3, endMonth: 3), "Mar 2021")
        XCTAssertEqual(ResumeRules.period(start: 2021, end: 2022, startMonth: 13), "2021 – 2022")

        let job = Experience(role: "Dev", organization: "Me", startYear: 2023, endYear: nil, highlights: [], startMonth: 2)
        XCTAssertEqual(job.period, "Feb 2023 – Present")
    }

    func testTechnologiesAreOrderedByHowOftenTheyAreUsed() {
        let projects = [
            Fixtures.project("a", technologies: ["SwiftUI", "WidgetKit"]),
            Fixtures.project("b", technologies: ["UIKit", "SwiftUI"]),
            Fixtures.project("c", technologies: ["SwiftUI", "Core ML", "UIKit"]),
        ]

        XCTAssertEqual(ResumeRules.technologies(in: projects), ["SwiftUI", "UIKit", "Core ML", "WidgetKit"])
    }

    func testFeaturedProjectsComeFirstInTheirOriginalOrder() {
        let projects = [
            Fixtures.project("a", technologies: ["UIKit"]),
            Fixtures.project("b", technologies: ["SwiftUI"], featured: true),
            Fixtures.project("c", technologies: ["SwiftUI"]),
            Fixtures.project("d", technologies: ["SwiftUI"], featured: true),
        ]

        XCTAssertEqual(ResumeRules.projects(projects).map(\.id), ["b", "d", "a", "c"])
        XCTAssertEqual(ResumeRules.projects(projects, using: "SwiftUI").map(\.id), ["b", "d", "c"])
        XCTAssertEqual(ResumeRules.projects(projects, using: "Metal"), [])
    }

    func testMailLinksCarryAnEncodedSubject() throws {
        let url = try XCTUnwrap(ResumeRules.mailURL(to: "me@example.com", subject: "Hello from Folio & co"))

        XCTAssertEqual(url.scheme, "mailto")
        XCTAssertEqual(url.absoluteString, "mailto:me@example.com?subject=Hello%20from%20Folio%20%26%20co")
    }

    func testCVFileNames() {
        XCTAssertEqual(ResumeRules.cvFileName(for: "Irina Poghosyan"), "Irina-Poghosyan-CV.pdf")
        XCTAssertEqual(ResumeRules.cvFileName(for: "  Anna-Maria  O'Neil "), "Anna-Maria-O-Neil-CV.pdf")
        XCTAssertEqual(ResumeRules.cvFileName(for: ""), "CV.pdf")
    }

    func testHexColors() {
        XCTAssertEqual(ResumeRules.rgb(fromHex: "#7C5CFF"), RGB(red: 124, green: 92, blue: 255))
        XCTAssertEqual(ResumeRules.rgb(fromHex: "38c878"), RGB(red: 56, green: 200, blue: 120))
        XCTAssertNil(ResumeRules.rgb(fromHex: "#FFF"))
        XCTAssertNil(ResumeRules.rgb(fromHex: "#GGGGGG"))
    }

    func testProblemsAreExplained() throws {
        let http = try XCTUnwrap(URL(string: "http://example.com"))
        let resume = Fixtures.resume(
            email: "not-an-email",
            links: [ContactLink(kind: .website, title: "Site", url: http)],
            projects: [
                Fixtures.project("a", technologies: []),
                Fixtures.project("a", technologies: ["SwiftUI"], accent: "blue", repository: "https://gitlab.com/x"),
            ],
            experience: [
                Experience(role: "Dev", organization: "Me", startYear: 2024, endYear: 2020, highlights: []),
                Experience(role: "QA", organization: "Me", startYear: 2020, endYear: 2021, highlights: [], startMonth: 0),
            ]
        )

        XCTAssertEqual(ResumeRules.problems(in: resume), [
            "The email address looks wrong.",
            "Site should be an https link.",
            "Two projects share an id.",
            "A lists no technologies.",
            "A has an invalid accent color.",
            "A should link to GitHub.",
            "Dev ends before it starts.",
            "QA has a month outside 1–12.",
        ])
    }

    func testAGoodResumeHasNoProblems() {
        let resume = Fixtures.resume(projects: [Fixtures.project("a", technologies: ["SwiftUI"])])
        XCTAssertEqual(ResumeRules.problems(in: resume), [])
    }
}
