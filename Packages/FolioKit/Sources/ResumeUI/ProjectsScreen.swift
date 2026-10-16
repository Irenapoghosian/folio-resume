import ResumeCore
import SwiftUI

/// Every app I've built, filterable by technology.
struct ProjectsScreen: View {
    @Bindable var model: ResumeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    filterBar
                    Text(model.projectCountText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                    ForEach(model.visibleProjects) { project in
                        NavigationLink(value: project.id) {
                            ProjectCard(project: project)
                        }
                        .buttonStyle(.plain)
                        .transition(.opacity.combined(with: .scale(scale: 0.97)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: model.selectedTechnology)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Projects")
            .navigationDestination(for: String.self) { id in
                if let project = model.resume.projects.first(where: { $0.id == id }) {
                    ProjectDetailScreen(project: project)
                }
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                Button {
                    model.selectedTechnology = nil
                } label: {
                    Chip(text: "All", isSelected: model.selectedTechnology == nil)
                }
                ForEach(model.technologies, id: \.self) { technology in
                    Button {
                        model.toggle(technology)
                    } label: {
                        Chip(text: technology, isSelected: model.selectedTechnology == technology)
                    }
                    .accessibilityAddTraits(model.selectedTechnology == technology ? .isSelected : [])
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
        .sensoryFeedback(.selection, trigger: model.selectedTechnology)
    }
}

/// Icon, name and tagline over the project's accent, a first screenshot, and its main technologies.
struct ProjectCard: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AppIconView(name: project.icon)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(project.name).font(.headline)
                        if project.featured {
                            Image(systemName: "star.fill").font(.caption).foregroundStyle(.yellow).accessibilityLabel("Featured")
                        }
                    }
                    Text(project.tagline).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(.tertiary)
            }
            Text(project.summary).font(.subheadline).foregroundStyle(.secondary).lineLimit(3)
            FlowLayout(spacing: 6) {
                ForEach(project.technologies.prefix(4), id: \.self) { technology in
                    Chip(text: technology, tint: Color(hex: project.accent))
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color(hex: project.accent).opacity(0.16), Color(.secondarySystemGroupedBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(.primary.opacity(0.06)))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Shows screenshots and details")
    }
}
