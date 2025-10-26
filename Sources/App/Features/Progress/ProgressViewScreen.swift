import SwiftUI
import Domain

struct ProgressViewScreen: View {
    @EnvironmentObject private var viewModel: ProgressViewModel

    var body: some View {
        NavigationStack {
            List {
                if let summary = viewModel.summary {
                    Section("Összkép") {
                        ProgressSummaryRow(title: "Edzések", value: "\(summary.workoutCount)")
                        ProgressSummaryRow(title: "Teljes volumen", value: "\(Int(summary.totalVolume)) kg")
                        ProgressSummaryRow(title: "Átlag intenzitás", value: String(format: "%.1f kg/szett", summary.averageIntensity))
                        if let weight = summary.latestWeight {
                            ProgressSummaryRow(title: "Legfrissebb testsúly", value: String(format: "%.1f kg", weight))
                        }
                    }

                    Section("Izomcsoport eloszlás") {
                        ForEach(summary.volumeByMuscleGroup.sorted(by: { $0.key.localizedName < $1.key.localizedName }), id: \.key) { entry in
                            HStack {
                                Text(entry.key.localizedName)
                                Spacer()
                                Text("\(Int(entry.value)) kg")
                            }
                        }
                    }
                } else {
                    ContentUnavailableView("Nincs adat", systemImage: "chart.bar", description: Text("Rögzíts edzéseket a statisztikákhoz."))
                }
            }
            .navigationTitle("Haladás")
            .toolbar {
                Button(action: { Task { await viewModel.refresh() } }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .task { await viewModel.refresh() }
        }
    }
}

private struct ProgressSummaryRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .font(.headline)
        }
    }
}
