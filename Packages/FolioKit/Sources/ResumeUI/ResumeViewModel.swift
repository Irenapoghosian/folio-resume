import Foundation
import Observation
import ResumeCore

/// The résumé on screen, the project filter, and the PDF CV.
@MainActor
@Observable
public final class ResumeViewModel {
    public let resume: Resume
    /// The technology the project list is narrowed to; `nil` shows everything.
    public var selectedTechnology: String?
    /// The PDF CV, written once and shared from the profile.
    public private(set) var cvURL: URL?
    public private(set) var cvFailed = false

    @ObservationIgnored private let exportCV: @MainActor (Resume) throws -> URL

    public init(resume: Resume, exportCV: @escaping @MainActor (Resume) throws -> URL = CVExporter.writePDF(for:)) {
        self.resume = resume
        self.exportCV = exportCV
    }

    public var technologies: [String] {
        ResumeRules.technologies(in: resume.projects)
    }

    public var visibleProjects: [Project] {
        ResumeRules.projects(resume.projects, using: selectedTechnology)
    }

    /// Tapping the selected chip again clears the filter.
    public func toggle(_ technology: String) {
        selectedTechnology = selectedTechnology == technology ? nil : technology
    }

    public var mailURL: URL? {
        ResumeRules.mailURL(to: resume.contact.email, subject: "Hello from your Folio app")
    }

    /// "2 projects with SwiftUI" under the filter, or "7 projects".
    public var projectCountText: String {
        let count = visibleProjects.count
        let noun = count == 1 ? "project" : "projects"
        guard let selectedTechnology else { return "\(count) \(noun)" }
        return "\(count) \(noun) with \(selectedTechnology)"
    }

    /// Writes the PDF the first time it's needed.
    public func prepareCV() {
        guard cvURL == nil else { return }
        do {
            cvURL = try exportCV(resume)
            cvFailed = false
        } catch {
            cvFailed = true
        }
    }
}
