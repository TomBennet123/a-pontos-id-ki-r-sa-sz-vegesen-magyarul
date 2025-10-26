import SwiftUI
import Domain

struct ProgressViewScreen: View {
    @EnvironmentObject private var viewModel: ProgressViewModel

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if let summary = viewModel.summary {
                        GymCard(title: "Összkép", icon: "chart.bar.xaxis") {
                            VStack(alignment: .leading, spacing: 12) {
                                ProgressSummaryRow(title: "Edzések", value: "\(summary.workoutCount)")
                                ProgressSummaryRow(title: "Teljes volumen", value: "\(Int(summary.totalVolume)) kg")
                                ProgressSummaryRow(title: "Átlag intenzitás", value: String(format: "%.1f kg/szett", summary.averageIntensity))
                                if let weight = summary.latestWeight {
                                    ProgressSummaryRow(title: "Legfrissebb testsúly", value: String(format: "%.1f kg", weight))
                                }
                            }
                        }

                        GymCard(title: "Izomcsoport eloszlás", icon: "figure.core.training") {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(summary.volumeByMuscleGroup.sorted(by: { $0.key.localizedName < $1.key.localizedName }), id: \.key) { entry in
                                    HStack {
                                        Text(entry.key.localizedName)
                                        Spacer()
                                        Text("\(Int(entry.value)) kg")
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.vertical, 6)
                                    Divider()
                                }
                            }
                        }
                    } else {
                        GymCard(title: "Nincs adat", icon: "chart.line.downtrend.xyaxis") {
                            Text("Rögzíts edzéseket a statisztikák megjelenítéséhez.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(
                LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            )
            .navigationTitle("Haladás")
            .toolbar {
                Button(action: { Task { await viewModel.refresh() } }) {
                    Image(systemName: viewModel.isLoading ? "hourglass" : "arrow.clockwise")
                }
                .disabled(viewModel.isLoading)
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
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.headline)
        }
        .padding(.vertical, 4)
    }
}
