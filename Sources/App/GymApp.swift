import SwiftUI
import Domain
import Persistence
import Health
import AICore

@main
struct GymApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            GymTabView()
                .environmentObject(container.dashboardViewModel)
                .environmentObject(container.workoutViewModel)
                .environmentObject(container.progressViewModel)
                .environmentObject(container.aiCoachViewModel)
        }
    }
}
