import SwiftUI
import Domain

struct TagCloud: View {
    let tags: [AIInsight.InsightKind]

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(label(for: tag))
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.accentColor.opacity(0.12)))
            }
        }
    }

    private func label(for tag: AIInsight.InsightKind) -> String {
        switch tag {
        case .motivation: return "Motiváció"
        case .recommendation: return "Ajánlás"
        case .warning: return "Figyelmeztetés"
        case .deloadSuggestion: return "Deload"
        }
    }
}
