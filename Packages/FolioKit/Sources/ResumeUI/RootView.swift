import ResumeCore
import SwiftUI

enum FolioTab: String, CaseIterable {
    case profile
    case history
    case projects

    var title: String {
        switch self {
        case .profile: "Profile"
        case .history: "History"
        case .projects: "Projects"
        }
    }

    var symbolName: String {
        switch self {
        case .profile: "person.fill"
        case .history: "doc.text.fill"
        case .projects: "square.grid.2x2.fill"
        }
    }
}

/// Three tabs under a floating glass tab bar.
public struct FolioRootView: View {
    @State private var model: ResumeViewModel
    @State private var tab = FolioTab.profile
    @AppStorage("appearance") private var appearance = Appearance.system
    @Namespace private var tabHighlight

    public init(model: ResumeViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        TabView(selection: $tab) {
            ProfileScreen(model: model, appearance: $appearance).tag(FolioTab.profile)
            HistoryScreen(resume: model.resume).tag(FolioTab.history)
            ProjectsScreen(model: model).tag(FolioTab.projects)
        }
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) { tabBar }
        .preferredColorScheme(appearance.colorScheme)
    }

    private var tabBar: some View {
        HStack {
            ForEach(FolioTab.allCases, id: \.self) { item in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { tab = item }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: item.symbolName).font(.system(size: 18, weight: .semibold))
                        Text(item.title).font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(tab == item ? Color.accentColor : .secondary)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background {
                        if tab == item {
                            Capsule().fill(Color.accentColor.opacity(0.15)).matchedGeometryEffect(id: "tab", in: tabHighlight)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(tab == item ? .isSelected : [])
            }
        }
        .padding(6)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(.primary.opacity(0.08)))
        .shadow(color: .black.opacity(0.12), radius: 16, y: 6)
        .padding(.horizontal, 28)
        .padding(.bottom, 4)
        .sensoryFeedback(.selection, trigger: tab)
    }
}
