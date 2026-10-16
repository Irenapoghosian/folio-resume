import Foundation

/// The small decisions behind the screens, kept here so they are tested.
public enum ResumeRules {

    /// "2024 – Present", "Aug 2021 – 2022", or just "2024" for a single year.
    public static func period(start: Int, end: Int?, startMonth: Int? = nil, endMonth: Int? = nil) -> String {
        let from = date(year: start, month: startMonth)
        guard let end else { return "\(from) – Present" }
        let until = date(year: end, month: endMonth)
        return from == until ? from : "\(from) – \(until)"
    }

    private static let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    /// `nil` (no month given) or 1…12.
    private static func isMonth(_ month: Int?) -> Bool {
        guard let month else { return true }
        return (1...12).contains(month)
    }

    /// "Feb 2023", or "2023" without a valid month.
    private static func date(year: Int, month: Int?) -> String {
        guard let month, (1...12).contains(month) else { return "\(year)" }
        return "\(monthNames[month - 1]) \(year)"
    }

    /// Every technology used across the projects, the most used first.
    public static func technologies(in projects: [Project]) -> [String] {
        var counts: [String: Int] = [:]
        for technology in projects.flatMap(\.technologies) {
            counts[technology, default: 0] += 1
        }
        return counts.keys.sorted { lhs, rhs in
            let left = counts[lhs, default: 0]
            let right = counts[rhs, default: 0]
            return left == right ? lhs < rhs : left > right
        }
    }

    /// Featured projects first (keeping the file's order), optionally only those using a technology.
    public static func projects(_ projects: [Project], using technology: String? = nil) -> [Project] {
        let matching = projects.filter { project in
            technology.map { project.technologies.contains($0) } ?? true
        }
        return matching.filter(\.featured) + matching.filter { !$0.featured }
    }

    /// `mailto:` with a subject, so a message from the app is easy to spot.
    public static func mailURL(to email: String, subject: String) -> URL? {
        // Only letters and digits stay as they are: "&" or "=" in a subject must not break the query.
        guard let encoded = subject.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else { return nil }
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = email
        components.percentEncodedQuery = "subject=\(encoded)"
        return components.url
    }

    /// "Irina Poghosyan" → "Irina-Poghosyan-CV.pdf"
    public static func cvFileName(for name: String) -> String {
        let words = name.split(whereSeparator: { !$0.isLetter && !$0.isNumber })
        return (words.isEmpty ? "CV" : words.joined(separator: "-") + "-CV") + ".pdf"
    }

    /// "#7C5CFF" → (124, 92, 255); `nil` for anything else.
    public static func rgb(fromHex hex: String) -> RGB? {
        let digits = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard digits.count == 6, let value = Int(digits, radix: 16) else { return nil }
        return RGB(red: (value >> 16) & 0xFF, green: (value >> 8) & 0xFF, blue: value & 0xFF)
    }

    /// What's wrong with a résumé, in plain words. Empty means it's ready to ship.
    public static func problems(in resume: Resume) -> [String] {
        contactProblems(in: resume) + projectProblems(in: resume.projects) + periodProblems(in: resume)
    }

    private static func contactProblems(in resume: Resume) -> [String] {
        var problems: [String] = []
        if resume.profile.name.trimmingCharacters(in: .whitespaces).isEmpty { problems.append("The name is empty.") }
        if !resume.contact.email.contains("@") { problems.append("The email address looks wrong.") }
        for link in resume.contact.links where link.url.scheme != "https" {
            problems.append("\(link.title) should be an https link.")
        }
        return problems
    }

    private static func projectProblems(in projects: [Project]) -> [String] {
        var problems: [String] = []
        let ids = projects.map(\.id)
        if Set(ids).count != ids.count { problems.append("Two projects share an id.") }
        for project in projects {
            if project.technologies.isEmpty { problems.append("\(project.name) lists no technologies.") }
            if rgb(fromHex: project.accent) == nil { problems.append("\(project.name) has an invalid accent color.") }
            if project.repository.host != "github.com" { problems.append("\(project.name) should link to GitHub.") }
        }
        return problems
    }

    private static func periodProblems(in resume: Resume) -> [String] {
        var problems: [String] = []
        for item in resume.experience where (item.endYear ?? item.startYear) < item.startYear {
            problems.append("\(item.role) ends before it starts.")
        }
        for item in resume.experience where !isMonth(item.startMonth) || !isMonth(item.endMonth) {
            problems.append("\(item.role) has a month outside 1–12.")
        }
        for item in resume.education where (item.endYear ?? item.startYear) < item.startYear {
            problems.append("\(item.degree) ends before it starts.")
        }
        return problems
    }
}

/// An 8-bit color from a hex string.
public struct RGB: Equatable, Sendable {
    public let red: Int
    public let green: Int
    public let blue: Int

    public init(red: Int, green: Int, blue: Int) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}
