import ResumeCore
import SwiftUI

/// Light, dark, or whatever the phone uses; remembered between launches.
public enum Appearance: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    public var symbolName: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }
}

extension ContactLink.Kind {
    public var symbolName: String {
        switch self {
        case .upwork: "briefcase.fill"
        case .linkedin: "person.crop.square.fill"
        case .github: "chevron.left.forwardslash.chevron.right"
        case .website: "globe"
        }
    }
}

extension Color {
    /// A project's accent from "#RRGGBB", or the app's blue if the string isn't a color.
    public init(hex: String) {
        guard let rgb = ResumeRules.rgb(fromHex: hex) else {
            self = .blue
            return
        }
        self.init(red: Double(rgb.red) / 255, green: Double(rgb.green) / 255, blue: Double(rgb.blue) / 255)
    }
}
