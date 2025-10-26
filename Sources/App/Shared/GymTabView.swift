import SwiftUI

struct GymTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Főoldal", systemImage: "figure.strengthtraining.traditional")
                }
            WorkoutLoggingView()
                .tabItem {
                    Label("Edzés", systemImage: "plus.square.on.square")
                }
            ProgressViewScreen()
                .tabItem {
                    Label("Haladás", systemImage: "chart.line.uptrend.xyaxis")
                }
            AICoachView()
                .tabItem {
                    Label("AI Edző", systemImage: "brain")
                }
        }
    }
}
