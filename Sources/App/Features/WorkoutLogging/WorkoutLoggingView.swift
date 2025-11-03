import SwiftUI
import Domain

struct WorkoutLoggingView: View {
    @EnvironmentObject private var viewModel: WorkoutLoggingViewModel
    @State private var showingRoutinePicker = false
    @State private var selectedExercise: Exercise?

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    heroCard
                    featuredSection
                    activeWorkoutSection
                    summarySection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(
                LinearGradient(colors: [Color(.systemBackground), Color.accentColor.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            )
            .navigationTitle("Edzés rögzítése")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sablon") { showingRoutinePicker = true }
                        .font(.callout.weight(.semibold))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.save()
                    } label: {
                        if viewModel.isSaving {
                            ProgressView()
                        } else {
                            Text("Mentés")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .sheet(isPresented: $showingRoutinePicker) {
                RoutinePickerView(isPresented: $showingRoutinePicker)
                    .environmentObject(viewModel)
            }
            .sheet(item: $selectedExercise) { exercise in
                ExerciseDetailSheet(exercise: exercise) {
                    viewModel.addExerciseFromCatalog(exercise)
                }
                .presentationDetents([.medium, .large])
            }
            .alert("Mentési hiba", isPresented: Binding(get: { viewModel.saveError != nil }, set: { _ in viewModel.saveError = nil })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.saveError ?? "Ismeretlen hiba")
            }
        }
    }

    private var heroCard: some View {
        GymCard(title: "Napi edzés", icon: "sparkles.rectangle.stack") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Egyetlen érintéssel rögzítheted a szetteket, miközben az AI és a statisztikák folyamatosan követik a fejlődésed.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    metricTile(title: "Össztérfogat", value: "\(Int(viewModel.activeWorkout.volume)) kg")
                    metricTile(title: "Szett", value: "\(viewModel.activeWorkout.totalSets)")
                }
            }
        }
    }

    private var featuredSection: some View {
        GymCard(title: "Ajánlott gyakorlat", icon: "flame.fill") {
            if viewModel.featuredExercises.isEmpty {
                Text("Hamarosan új gyakorlatok érkeznek.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.featuredExercises) { exercise in
                            ExercisePreviewCard(exercise: exercise, onInfo: {
                                selectedExercise = exercise
                            }, onAdd: {
                                viewModel.addExerciseFromCatalog(exercise)
                            })
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var activeWorkoutSection: some View {
        GymCard(title: "Aktív napló", icon: "list.bullet.rectangle") {
            if viewModel.activeWorkout.entries.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Kezdj az ajánlott gyakorlattal, vagy válassz sablont a bal felső sarokban.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.activeWorkout.entries) { entry in
                        WorkoutEntryCard(entry: entry) {
                            viewModel.addRecommendedSet(to: entry.id)
                        } onRemove: {
                            viewModel.removeEntry(entry.id)
                        }
                    }
                }
            }
        }
    }

    private var summarySection: some View {
        GymCard(title: "Összesítés", icon: "sum") {
            VStack(alignment: .leading, spacing: 12) {
                summaryRow(title: "Térfogat", value: "\(Int(viewModel.activeWorkout.volume)) kg", icon: "dumbbell.fill")
                summaryRow(title: "Szett szám", value: "\(viewModel.activeWorkout.totalSets)", icon: "list.number")
                summaryRow(title: "Célzott izmok", value: viewModel.activeWorkout.musclesTargeted.map(\.localizedName).joined(separator: ", "), icon: "figure.strengthtraining.traditional")
            }
        }
    }

    private func metricTile(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.accentColor.opacity(0.12))
        )
    }

    private func summaryRow(title: String, value: String, icon: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.accent)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.callout)
                Text(value.isEmpty ? "-" : value)
                    .font(.headline)
            }
            Spacer()
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

private struct ExercisePreviewCard: View {
    let exercise: Exercise
    let onInfo: () -> Void
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let mediaURL = exercise.guidance?.mediaURL {
                AsyncImage(url: mediaURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 120)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 140)
                            .clipped()
                            .cornerRadius(16)
                    case .failure:
                        placeholderMedia
                    @unknown default:
                        placeholderMedia
                    }
                }
            } else {
                placeholderMedia
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(exercise.name)
                    .font(.headline)
                if let guidance = exercise.guidance {
                    Text(guidance.setSummaryText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Button(action: onInfo) {
                        Label("Részletek", systemImage: "info.circle")
                            .font(.caption)
                    }
                    Spacer()
                    Button(action: onAdd) {
                        Label("Hozzáad", systemImage: "plus.circle.fill")
                            .font(.caption)
                    }
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(16)
        .frame(width: 220)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground).opacity(0.9))
        )
    }

    private var placeholderMedia: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.accentColor.opacity(0.1))
            .overlay(
                Image(systemName: "dumbbell")
                    .font(.largeTitle)
                    .foregroundStyle(.accent)
            )
            .frame(height: 140)
    }
}

private struct WorkoutEntryCard: View {
    let entry: WorkoutEntry
    let onAddSet: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.exercise.name)
                        .font(.headline)
                    Text(entry.exercise.primaryMuscles.map(\.localizedName).joined(separator: ", "))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.borderless)
            }

            if let guidance = entry.exercise.guidance {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ajánlás")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text("Súly: \(guidance.recommendedWeightText)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(guidance.setSummaryText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(entry.sets) { set in
                    HStack {
                        Text("\(Int(set.weight)) kg")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(set.reps) ismétlés")
                        if let rpe = set.rpe {
                            Spacer()
                            Text("RPE \(String(format: "%.1f", rpe))")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.tertiarySystemBackground))
                    )
                }
            }

            HStack {
                Button(action: onAddSet) {
                    Label("Új szett", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)

                if let url = entry.exercise.guidance?.videoURL {
                    Spacer()
                    Link(destination: url) {
                        Label("Videó", systemImage: "play.rectangle")
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        )
    }
}

private struct ExerciseDetailSheet: View {
    let exercise: Exercise
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let mediaURL = exercise.guidance?.mediaURL {
                        AsyncImage(url: mediaURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(24)
                            case .failure:
                                placeholder
                            @unknown default:
                                placeholder
                            }
                        }
                    } else {
                        placeholder
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text(exercise.name)
                            .font(.title2.bold())
                        if let guidance = exercise.guidance {
                            Text("Cél: \(guidance.goal)")
                                .font(.body)
                            Text("Súly: \(guidance.recommendedWeightText)")
                                .font(.body)
                            Text("Sorozat: \(guidance.setSummaryText)")
                                .font(.body)
                            Text(guidance.detailedDescription)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        if let instructions = exercise.instructions {
                            Divider()
                            Text(instructions)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let videoURL = exercise.guidance?.videoURL {
                        Link(destination: videoURL) {
                            Label("Youtube videó megnyitása", systemImage: "play.rectangle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Gyakorlat")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hozzáadás") {
                        onAdd()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Bezárás") { dismiss() }
                }
            }
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.accentColor.opacity(0.1))
            .frame(maxWidth: .infinity, minHeight: 200)
            .overlay(
                Image(systemName: "dumbbell.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.accent)
            )
    }
}
