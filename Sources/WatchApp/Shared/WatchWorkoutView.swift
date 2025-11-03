import SwiftUI

struct WatchWorkoutView: View {
    @StateObject private var sessionManager = WorkoutSessionManager()

    var body: some View {
        VStack(spacing: 12) {
            Text("Gym")
                .font(.title2.bold())
            Text("Pulzus: \(Int(sessionManager.heartRate)) bpm")
                .font(.headline)
            Button("Edzés indítása") {
                #if canImport(WatchKit)
                try? sessionManager.startWorkout(activity: .traditionalStrengthTraining)
                #endif
            }
        }
    }
}
