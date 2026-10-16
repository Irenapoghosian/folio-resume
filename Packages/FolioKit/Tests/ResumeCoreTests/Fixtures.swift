import Foundation
import ResumeCore

enum Fixtures {
    static func project(
        _ id: String,
        technologies: [String],
        featured: Bool = false,
        accent: String = "#7C5CFF",
        repository: String = "https://github.com/Irenapoghosian/x"
    ) -> Project {
        Project(
            id: id,
            name: id.capitalized,
            tagline: "",
            summary: "",
            highlights: [],
            technologies: technologies,
            repository: URL(string: repository) ?? URL(fileURLWithPath: "/"),
            icon: "icon-\(id)",
            screenshots: [],
            accent: accent,
            featured: featured
        )
    }

    static func resume(
        email: String = "me@example.com",
        links: [ContactLink] = [],
        projects: [Project] = [],
        experience: [Experience] = []
    ) -> Resume {
        Resume(
            profile: Profile(name: "Irina Poghosyan", title: "iOS Developer", location: "Yerevan", availability: nil, summary: "", photo: nil),
            contact: Contact(email: email, links: links),
            skills: [],
            experience: experience,
            education: [],
            languages: [],
            projects: projects
        )
    }

    static let minimalJSON = """
    {
      "profile": { "name": "A B", "title": "iOS Developer", "location": "Yerevan", "summary": "Hi" },
      "contact": { "email": "a@b.com", "links": [ { "kind": "github", "title": "GitHub", "url": "https://github.com/a" } ] },
      "skills": [ { "name": "UI", "items": ["SwiftUI"] } ],
      "experience": [ { "role": "Dev", "organization": "Me", "startYear": 2024, "endYear": null, "highlights": [] } ],
      "education": [],
      "languages": [ { "name": "Armenian", "level": "Native" } ],
      "projects": []
    }
    """
}
