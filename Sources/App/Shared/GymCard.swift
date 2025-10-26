import SwiftUI

struct GymCard<Content: View>: View {
    let title: String
    let icon: String?
    @ViewBuilder let content: Content

    init(title: String, icon: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !title.isEmpty {
                HStack(spacing: 10) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundStyle(.accent)
                    }
                    Text(title)
                        .font(.title3.bold())
                    Spacer()
                }
            }

            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
        )
    }
}
