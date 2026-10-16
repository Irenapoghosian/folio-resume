import ResumeCore
import XCTest

final class ResumeLoaderTests: XCTestCase {
    func testTheShippedResumeLoadsAndHasNoProblems() throws {
        let resume = try ResumeLoader.bundled()

        XCTAssertEqual(ResumeRules.problems(in: resume), [])
        XCTAssertFalse(resume.projects.isEmpty)
        XCTAssertFalse(resume.experience.isEmpty)
        XCTAssertTrue(resume.projects.contains { $0.featured })
    }

    func testTheShippedResumeHasNoPhoneNumber() throws {
        let url = try XCTUnwrap(ResumeLoader.bundledFileURL)
        let text = try String(contentsOf: url, encoding: .utf8)

        // The repository is public: no phone numbers in any form.
        XCTAssertFalse(text.contains("+374"))
        XCTAssertFalse(text.contains("tel:"))
        XCTAssertNil(text.range(of: #"\+?\d[\d \-]{7,}\d"#, options: .regularExpression))
    }

    func testOptionalFieldsCanBeLeftOut() throws {
        let resume = try ResumeLoader.decode(Data(Fixtures.minimalJSON.utf8))

        XCTAssertNil(resume.profile.availability)
        XCTAssertNil(resume.profile.photo)
        XCTAssertNil(resume.experience.first?.endYear)
        XCTAssertEqual(resume.contact.links.first?.kind, .github)
    }

    func testBrokenFilesSayWhereTheProblemIs() {
        let broken = Fixtures.minimalJSON.replacingOccurrences(of: "\"title\": \"iOS Developer\", ", with: "")

        XCTAssertThrowsError(try ResumeLoader.decode(Data(broken.utf8))) { error in
            guard case ResumeLoader.LoadError.invalid(let message) = error else { return XCTFail("Unexpected \(error)") }
            XCTAssertEqual(message, "profile.title: missing")
        }
    }

    func testUnknownLinkKindsAreRejected() {
        let broken = Fixtures.minimalJSON.replacingOccurrences(of: "\"kind\": \"github\"", with: "\"kind\": \"myspace\"")

        XCTAssertThrowsError(try ResumeLoader.decode(Data(broken.utf8))) { error in
            guard case ResumeLoader.LoadError.invalid(let message) = error else { return XCTFail("Unexpected \(error)") }
            XCTAssertTrue(message.hasPrefix("contact.links[0].kind"), message)
        }
    }

    func testAMissingFileIsReported() {
        XCTAssertThrowsError(try ResumeLoader.load(named: "nope", in: .main)) { error in
            XCTAssertEqual(error as? ResumeLoader.LoadError, .missingFile)
        }
    }
}
