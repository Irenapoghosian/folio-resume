import SwiftUI

/// Lays chips out left to right, wrapping to a new line when the row is full.
public struct FlowLayout: Layout {
    public var spacing: CGFloat

    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let frames = Self.frames(for: sizes, maxWidth: proposal.width ?? .infinity, spacing: spacing)
        let width = frames.map(\.maxX).max() ?? 0
        let height = frames.map(\.maxY).max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let frames = Self.frames(for: sizes, maxWidth: bounds.width, spacing: spacing)
        for (subview, frame) in zip(subviews, frames) {
            subview.place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }

    /// Where each item goes, as plain geometry so it can be tested without a view.
    public static func frames(for sizes: [CGSize], maxWidth: CGFloat, spacing: CGFloat) -> [CGRect] {
        var frames: [CGRect] = []
        var left: CGFloat = 0
        var top: CGFloat = 0
        var rowHeight: CGFloat = 0
        for size in sizes {
            if left > 0 && left + size.width > maxWidth {
                left = 0
                top += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: left, y: top), size: size))
            left += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return frames
    }
}
