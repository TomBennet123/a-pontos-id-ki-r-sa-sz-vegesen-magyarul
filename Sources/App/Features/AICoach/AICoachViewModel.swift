import Foundation
import Domain

@MainActor
final class AICoachViewModel: ObservableObject {
    @Published private(set) var insight: AIInsight?
    @Published private(set) var isLoading = false

    private let generateAIInsightUseCase: GenerateAIInsightUseCase

    init(generateAIInsightUseCase: GenerateAIInsightUseCase) {
        self.generateAIInsightUseCase = generateAIInsightUseCase
    }

    func generate(for workout: Workout) {
        Task {
            guard !isLoading else { return }
            isLoading = true
            defer { isLoading = false }
            do {
                insight = try await generateAIInsightUseCase.execute(for: workout)
            } catch {
                print("Insight generation failed: \(error)")
            }
        }
    }
}
