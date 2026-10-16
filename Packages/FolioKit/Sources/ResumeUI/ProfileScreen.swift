import ResumeCore
import SwiftUI

/// Photo, who I am, how to reach me, the CV, skills and languages.
struct ProfileScreen: View {
    let model: ResumeViewModel
    @Binding var appearance: Appearance
    @State private var appeared = false

    private var resume: Resume { model.resume }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    ProfileHeader(profile: resume.profile)
                    actions
                    links
                    SectionCard(title: "About me") {
                        Text(resume.profile.summary).foregroundStyle(.secondary).lineSpacing(4)
                    }
                    SkillsCard(groups: resume.skills)
                    SectionCard(title: "Languages") {
                        FlowLayout(spacing: 8) {
                            ForEach(resume.languages) { language in
                                Chip(text: "\(language.name) · \(language.level)", tint: .purple)
                            }
                        }
                    }
                    Text("Built with SwiftUI · every word comes from resume.json")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
            }
            .toolbar { appearanceMenu }
            .task {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { appeared = true }
                model.prepareCV()
            }
        }
    }

    private var actions: some View {
        HStack(spacing: 12) {
            if let mail = model.mailURL {
                Link(destination: mail) {
                    Label("Email me", systemImage: "envelope.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            if let cvFile = model.cvURL {
                ShareLink(item: cvFile, preview: SharePreview("\(resume.profile.name) — CV")) {
                    Label("Download CV", systemImage: "arrow.down.doc.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            } else {
                Label(model.cvFailed ? "CV unavailable" : "Preparing CV…", systemImage: "doc")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.secondary)
            }
        }
        .controlSize(.large)
    }

    private var links: some View {
        HStack(spacing: 10) {
            ForEach(resume.contact.links) { link in
                Link(destination: link.url) {
                    Label(link.title, systemImage: link.kind.symbolName)
                        .font(.footnote.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    private var appearanceMenu: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Picker("Appearance", selection: $appearance) {
                    ForEach(Appearance.allCases) { option in
                        Label(option.title, systemImage: option.symbolName).tag(option)
                    }
                }
            } label: {
                Image(systemName: appearance.symbolName)
            }
            .accessibilityLabel("Appearance")
        }
    }
}

struct ProfileHeader: View {
    let profile: Profile

    var body: some View {
        VStack(spacing: 12) {
            if let photo = profile.photo {
                Image(photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3))
                    .shadow(color: .blue.opacity(0.25), radius: 14, y: 8)
                    .accessibilityLabel("Photo of \(profile.name)")
            }
            Text(profile.name).font(.system(size: 30, weight: .bold, design: .rounded))
            Text(profile.title)
                .font(.headline)
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(Color.accentColor.opacity(0.12), in: Capsule())
            HStack(spacing: 10) {
                Label(profile.location, systemImage: "mappin.and.ellipse")
                if let availability = profile.availability {
                    HStack(spacing: 5) {
                        Circle().fill(.green).frame(width: 7, height: 7)
                        Text(availability)
                    }
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
    }
}

struct SkillsCard: View {
    let groups: [SkillGroup]

    var body: some View {
        SectionCard(title: "Skills") {
            ForEach(groups) { group in
                VStack(alignment: .leading, spacing: 8) {
                    Text(group.name).font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                    FlowLayout(spacing: 8) {
                        ForEach(group.items, id: \.self) { item in
                            Chip(text: item)
                        }
                    }
                }
            }
        }
    }
}
