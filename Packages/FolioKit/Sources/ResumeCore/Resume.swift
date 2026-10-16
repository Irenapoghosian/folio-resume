import Foundation

/// Everything the app shows, decoded from `resume.json`.
public struct Resume: Codable, Equatable, Sendable {
    public let profile: Profile
    public let contact: Contact
    public let skills: [SkillGroup]
    public let experience: [Experience]
    public let education: [Education]
    public let languages: [Language]
    public let projects: [Project]

    public init(
        profile: Profile,
        contact: Contact,
        skills: [SkillGroup],
        experience: [Experience],
        education: [Education],
        languages: [Language],
        projects: [Project]
    ) {
        self.profile = profile
        self.contact = contact
        self.skills = skills
        self.experience = experience
        self.education = education
        self.languages = languages
        self.projects = projects
    }
}

public struct Profile: Codable, Equatable, Sendable {
    public let name: String
    public let title: String
    public let location: String
    public let availability: String?
    public let summary: String
    /// The asset name of the photo in the app's asset catalog.
    public let photo: String?

    public init(name: String, title: String, location: String, availability: String?, summary: String, photo: String?) {
        self.name = name
        self.title = title
        self.location = location
        self.availability = availability
        self.summary = summary
        self.photo = photo
    }
}

/// Ways to get in touch. There is deliberately no phone number: the repository is public.
public struct Contact: Codable, Equatable, Sendable {
    public let email: String
    public let links: [ContactLink]

    public init(email: String, links: [ContactLink]) {
        self.email = email
        self.links = links
    }
}

public struct ContactLink: Codable, Equatable, Identifiable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case upwork
        case linkedin
        case github
        case website
    }

    public let kind: Kind
    public let title: String
    public let url: URL

    public init(kind: Kind, title: String, url: URL) {
        self.kind = kind
        self.title = title
        self.url = url
    }

    public var id: String { url.absoluteString }
}

public struct SkillGroup: Codable, Equatable, Identifiable, Sendable {
    public let name: String
    public let items: [String]

    public init(name: String, items: [String]) {
        self.name = name
        self.items = items
    }

    public var id: String { name }
}

public struct Experience: Codable, Equatable, Identifiable, Sendable {
    public let role: String
    public let organization: String
    public let startYear: Int
    /// `nil` while it's still going on.
    public let endYear: Int?
    public let highlights: [String]
    /// 1…12 when the month matters ("Feb 2023"), otherwise just the year is shown.
    public let startMonth: Int?
    public let endMonth: Int?

    public init(
        role: String,
        organization: String,
        startYear: Int,
        endYear: Int?,
        highlights: [String],
        startMonth: Int? = nil,
        endMonth: Int? = nil
    ) {
        self.role = role
        self.organization = organization
        self.startYear = startYear
        self.endYear = endYear
        self.highlights = highlights
        self.startMonth = startMonth
        self.endMonth = endMonth
    }

    /// "Feb 2023 – Present"
    public var period: String {
        ResumeRules.period(start: startYear, end: endYear, startMonth: startMonth, endMonth: endMonth)
    }

    public var id: String { "\(role)@\(organization)" }
}

public struct Education: Codable, Equatable, Identifiable, Sendable {
    public let degree: String
    public let institution: String
    public let startYear: Int
    public let endYear: Int?

    public init(degree: String, institution: String, startYear: Int, endYear: Int?) {
        self.degree = degree
        self.institution = institution
        self.startYear = startYear
        self.endYear = endYear
    }

    /// "2022 – 2024"
    public var period: String {
        ResumeRules.period(start: startYear, end: endYear)
    }

    public var id: String { "\(degree)@\(institution)" }
}

public struct Language: Codable, Equatable, Identifiable, Sendable {
    public let name: String
    public let level: String

    public init(name: String, level: String) {
        self.name = name
        self.level = level
    }

    public var id: String { name }
}

public struct Project: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let tagline: String
    public let summary: String
    public let highlights: [String]
    public let technologies: [String]
    public let repository: URL
    /// Asset names in the app's catalog.
    public let icon: String
    public let screenshots: [String]
    /// "#RRGGBB", tints the project's card.
    public let accent: String
    /// Featured projects come first.
    public let featured: Bool

    public init(
        id: String,
        name: String,
        tagline: String,
        summary: String,
        highlights: [String],
        technologies: [String],
        repository: URL,
        icon: String,
        screenshots: [String],
        accent: String,
        featured: Bool
    ) {
        self.id = id
        self.name = name
        self.tagline = tagline
        self.summary = summary
        self.highlights = highlights
        self.technologies = technologies
        self.repository = repository
        self.icon = icon
        self.screenshots = screenshots
        self.accent = accent
        self.featured = featured
    }
}
