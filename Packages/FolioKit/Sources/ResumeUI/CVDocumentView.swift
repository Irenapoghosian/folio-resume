import ResumeCore
import SwiftUI

/// The one-page A4 CV drawn into the PDF, in the layout of my original CV: a photo over a header band,
/// a soft sidebar with contact, education, skills and languages, and the story on the right.
struct CVDocumentView: View {
    let resume: Resume

    private let band = Color(red: 0.84, green: 0.87, blue: 0.91)
    private let ink = Color(red: 0.27, green: 0.29, blue: 0.35)
    private let muted = Color(red: 0.48, green: 0.50, blue: 0.56)
    private let link = Color(red: 0.24, green: 0.38, blue: 0.62)

    private let sidebarWidth: CGFloat = 196
    private let headerTop: CGFloat = 34
    private let bodyTop: CGFloat = 222

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.white
            UnevenRoundedRectangle(topTrailingRadius: 38)
                .fill(band)
                .frame(width: sidebarWidth, height: CVExporter.pageSize.height - bodyTop + 12)
                .offset(y: bodyTop - 12)
            Rectangle()
                .fill(band)
                .frame(width: CVExporter.pageSize.width - 150, height: 128)
                .offset(x: 150, y: headerTop)
            photo.offset(x: 36, y: 18)
            nameBlock.offset(x: 226, y: headerTop + 30)
            sidebar
                .frame(width: sidebarWidth - 44, alignment: .leading)
                .offset(x: 24, y: bodyTop + 22)
            mainColumn
                .frame(width: CVExporter.pageSize.width - sidebarWidth - 54, alignment: .leading)
                .offset(x: sidebarWidth + 26, y: bodyTop - 4)
        }
        .frame(width: CVExporter.pageSize.width, height: CVExporter.pageSize.height, alignment: .topLeading)
        .environment(\.colorScheme, .light)
    }

    // MARK: - Header

    @ViewBuilder
    private var photo: some View {
        if let name = resume.profile.photo {
            Image(name)
                .resizable()
                .scaledToFill()
                .frame(width: 160, height: 160)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 5))
        }
    }

    private var nameBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(resume.profile.name.uppercased())
                .font(.system(size: 27, weight: .medium))
                .kerning(2.6)
                .foregroundStyle(ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(resume.profile.title)
                .font(.system(size: 15, weight: .semibold))
                .kerning(0.6)
                .foregroundStyle(ink)
        }
        .frame(width: CVExporter.pageSize.width - 226 - 30, alignment: .leading)
    }

    private func heading(_ title: String, size: CGFloat = 12.5) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased()).font(.system(size: size, weight: .medium)).kerning(1.4).foregroundStyle(ink)
            Rectangle().fill(ink.opacity(0.45)).frame(height: 0.8)
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 18) {
            contact
            VStack(alignment: .leading, spacing: 8) {
                heading("Education")
                ForEach(resume.education) { item in
                    VStack(alignment: .leading, spacing: 1.5) {
                        Text(item.degree).font(.system(size: 10.5)).foregroundStyle(ink)
                        Text(item.institution).font(.system(size: 8, weight: .semibold)).foregroundStyle(ink)
                        Text(item.period).font(.system(size: 7.5)).foregroundStyle(muted)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 7) {
                heading("Skills")
                ForEach(resume.skills) { group in
                    VStack(alignment: .leading, spacing: 1.5) {
                        Text(group.name).font(.system(size: 8, weight: .semibold)).foregroundStyle(ink)
                        Text(group.items.joined(separator: " · ")).font(.system(size: 7.5)).foregroundStyle(muted).lineSpacing(1.5)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 7) {
                heading("Languages")
                LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], spacing: 6) {
                    ForEach(resume.languages) { language in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(language.name).font(.system(size: 9.5)).foregroundStyle(ink)
                            Text(language.level).font(.system(size: 7)).foregroundStyle(muted)
                        }
                    }
                }
            }
        }
    }

    private var contact: some View {
        VStack(alignment: .leading, spacing: 7) {
            contactRow("envelope", resume.contact.email)
            contactRow("mappin.and.ellipse", resume.profile.location)
            ForEach(resume.contact.links) { item in
                contactRow(item.kind.symbolName, shortLink(item.url))
            }
        }
    }

    private func contactRow(_ symbol: String, _ text: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: symbol).font(.system(size: 9)).frame(width: 12).foregroundStyle(ink)
            Text(text).font(.system(size: 7.5)).foregroundStyle(ink).lineLimit(1).minimumScaleFactor(0.7)
        }
    }

    /// "github.com/Irenapoghosian" instead of the full URL.
    private func shortLink(_ url: URL) -> String {
        let host = (url.host() ?? "").replacingOccurrences(of: "www.", with: "")
        let path = url.path().trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return path.isEmpty ? host : "\(host)/\(path)"
    }

    // MARK: - Main column

    private var mainColumn: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                heading("About me", size: 14)
                Text(resume.profile.summary).font(.system(size: 8.5)).foregroundStyle(ink).lineSpacing(2)
            }
            VStack(alignment: .leading, spacing: 10) {
                heading("Work experience", size: 14)
                ForEach(resume.experience) { item in
                    experienceItem(item)
                }
            }
            VStack(alignment: .leading, spacing: 7) {
                heading("Selected projects", size: 14)
                ForEach(resume.projects.filter(\.featured)) { project in
                    VStack(alignment: .leading, spacing: 1) {
                        Text("\(project.name) — \(project.tagline)").font(.system(size: 9.5, weight: .semibold)).foregroundStyle(ink)
                        Text(project.technologies.joined(separator: " · ")).font(.system(size: 7.5)).foregroundStyle(muted)
                        Text(shortLink(project.repository)).font(.system(size: 7.5)).foregroundStyle(link)
                    }
                }
            }
        }
    }

    private func experienceItem(_ item: Experience) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.period).font(.system(size: 8.5)).kerning(0.4).foregroundStyle(muted)
            Text(item.organization.uppercased()).font(.system(size: 7.5)).kerning(0.6).foregroundStyle(muted)
            Text(item.role).font(.system(size: 12)).foregroundStyle(ink).padding(.bottom, 2)
            ForEach(item.highlights, id: \.self) { line in
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("•")
                    Text(line).lineSpacing(1.5)
                }
                .font(.system(size: 8))
                .foregroundStyle(ink)
            }
        }
    }
}
