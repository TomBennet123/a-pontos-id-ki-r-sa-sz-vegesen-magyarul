import SwiftUI
import Domain

struct WorkoutLoggingView: View {
    @EnvironmentObject private var viewModel: WorkoutLoggingViewModel
    @State private var showingRoutinePicker = false

    var body: some View {
        NavigationStack {
            List {
                Section("Aktív edzés") {
                    ForEach(viewModel.activeWorkout.entries) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.exercise.name)
                                .font(.headline)
                            ForEach(entry.sets) { set in
                                HStack {
                                    Text("\(Int(set.weight)) kg")
                                    Spacer()
                                    Text("\(set.reps) ismétlés")
                                    if let rpe = set.rpe {
                                        Spacer()
                                        Text("RPE \(String(format: "%.1f", rpe))")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            Button("Új szett") {
                                viewModel.addSet(to: entry.id, set: WorkoutSet(weight: 20, reps: 8))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        viewModel.activeWorkout.entries.remove(atOffsets: indexSet)
                    }
                }

                Section("Összesítés") {
                    HStack {
                        Label("Térfogat", systemImage: "dumbbell.fill")
                        Spacer()
                        Text("\(Int(viewModel.activeWorkout.volume)) kg")
                    }
                    HStack {
                        Label("Szett szám", systemImage: "list.number")
                        Spacer()
                        Text("\(viewModel.activeWorkout.totalSets)")
                    }
                }
            }
            .navigationTitle("Edzés rögzítése")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sablon") { showingRoutinePicker = true }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Mentés") { viewModel.save() }
                        .disabled(viewModel.isSaving)
                }
            }
            .sheet(isPresented: $showingRoutinePicker) {
                RoutinePickerView(isPresented: $showingRoutinePicker)
                    .environmentObject(viewModel)
            }
            .alert("Mentési hiba", isPresented: Binding(get: { viewModel.saveError != nil }, set: { _ in viewModel.saveError = nil })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.saveError ?? "Ismeretlen hiba")
            }
        }
    }
}

private struct RoutinePickerView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: WorkoutLoggingViewModel
    @State private var routines: [Routine] = []

    var body: some View {
        NavigationStack {
            List(routines) { routine in
                Button {
                    viewModel.applyRoutine(routine)
                    isPresented = false
                } label: {
                    VStack(alignment: .leading) {
                        Text(routine.name)
                            .font(.headline)
                        Text(routine.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Rutinválasztó")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Mégse") { isPresented = false }
                }
            }
            .task {
                do {
                    routines = try await viewModel.availableRoutines()
                } catch {
                    print("Routine fetch error: \(error)")
                }
            }
        }
    }
}
