import ResumeCore
import SafariServices
import SwiftUI

/// A rounded tag for a skill or technology.
struct Chip: View {
    let text: String
    var tint: Color = .blue
    var isSelected = false

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(isSelected ? Color.white : tint)
            .background(isSelected ? tint : tint.opacity(0.12), in: Capsule())
    }
}

/// A titled block on a soft background.
struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title3.weight(.bold)).accessibilityAddTraits(.isHeader)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

/// A project's app icon from the asset catalog.
struct AppIconView: View {
    let name: String
    var size: CGFloat = 52

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.225, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: size * 0.225, style: .continuous).strokeBorder(.primary.opacity(0.08)))
            .accessibilityHidden(true)
    }
}

/// GitHub inside the app, so the visitor never leaves the résumé.
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}

/// Lets `.sheet(item:)` present a URL.
struct IdentifiableURL: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}
