import ResumeCore
import SwiftUI

/// Screenshots, what it does, what's interesting about it, and a way to the code.
struct ProjectDetailScreen: View {
    let project: Project
    @State private var openedURL: IdentifiableURL?

    private var accent: Color { Color(hex: project.accent) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                if !project.screenshots.isEmpty {
                    screenshots
                }
                SectionCard(title: "About") {
                    Text(project.summary).foregroundStyle(.secondary).lineSpacing(4)
                }
                SectionCard(title: "Highlights") {
                    ForEach(project.highlights, id: \.self) { line in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Image(systemName: "sparkle").foregroundStyle(accent)
                            Text(line)
                        }
                    }
                }
                SectionCard(title: "Built with") {
                    FlowLayout(spacing: 8) {
                        ForEach(project.technologies, id: \.self) { Chip(text: $0, tint: accent) }
                    }
                }
                Button {
                    openedURL = IdentifiableURL(url: project.repository)
                } label: {
                    Label("View the code on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(accent)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $openedURL) { item in
            SafariView(url: item.url).ignoresSafeArea()
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            AppIconView(name: project.icon, size: 76)
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name).font(.title.weight(.bold))
                Text(project.tagline).font(.headline).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(colors: [accent.opacity(0.35), accent.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .padding(.top, 8)
    }

    private var screenshots: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 14) {
                ForEach(project.screenshots, id: \.self) { name in
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 380)
                        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
                        .accessibilityLabel("\(project.name) screenshot")
                }
            }
            .padding(.vertical, 6)
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
    }
}
