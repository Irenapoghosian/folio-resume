import ResumeCore
import SwiftUI

/// Experience and education on a timeline.
struct HistoryScreen: View {
    enum Part: String, CaseIterable {
        case experience = "Experience"
        case education = "Education"
    }

    let resume: Resume
    @State private var part = Part.experience

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Picker("Show", selection: $part) {
                        ForEach(Part.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 20)

                    switch part {
                    case .experience:
                        ForEach(Array(resume.experience.enumerated()), id: \.element.id) { index, item in
                            TimelineRow(
                                title: item.role,
                                subtitle: item.organization,
                                period: item.period,
                                bullets: item.highlights,
                                isCurrent: item.endYear == nil,
                                isLast: index == resume.experience.count - 1
                            )
                        }
                    case .education:
                        ForEach(Array(resume.education.enumerated()), id: \.element.id) { index, item in
                            TimelineRow(
                                title: item.degree,
                                subtitle: item.institution,
                                period: item.period,
                                bullets: [],
                                isCurrent: item.endYear == nil,
                                isLast: index == resume.education.count - 1
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .animation(.easeInOut(duration: 0.25), value: part)
            }
            .navigationTitle("History")
            .background(Color(.systemGroupedBackground))
        }
    }
}

/// A dot on the line, then the title, place, years and highlights.
struct TimelineRow: View {
    let title: String
    let subtitle: String
    let period: String
    let bullets: [String]
    let isCurrent: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                Circle()
                    .fill(isCurrent ? Color.green : Color.accentColor)
                    .frame(width: 12, height: 12)
                    .padding(.top, 5)
                if !isLast {
                    Rectangle().fill(Color.secondary.opacity(0.25)).frame(width: 2)
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
                Text(period)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.accentColor.opacity(0.1), in: Capsule())
                ForEach(bullets, id: \.self) { line in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.accentColor)
                        Text(line)
                    }
                    .font(.subheadline)
                }
            }
            .padding(.bottom, 28)
        }
        .accessibilityElement(children: .combine)
    }
}
