import Foundation
import Combine
import Domain
import Persistence
import Health
import AICore

@MainActor
final class AppContainer: ObservableObject {
    let workoutRepository: WorkoutRepository
    let routineRepository: RoutineRepository
    let bodyMetricRepository: BodyMetricRepository
    let aiInsightRepository: AIInsightRepository
    let aiRecommender: AIRecommender

    let dashboardViewModel: DashboardViewModel
    let workoutViewModel: WorkoutLoggingViewModel
    let progressViewModel: ProgressViewModel
    let aiCoachViewModel: AICoachViewModel

    init() {
        let workoutRepository = WorkoutRepositoryImpl()
        let routineRepository = RoutineRepositoryImpl()
        let bodyMetricRepository = BodyMetricRepositoryImpl()
        let aiInsightRepository = AIInsightRepositoryImpl()
        let aiRecommender = OfflineAIRecommender()

        self.workoutRepository = workoutRepository
        self.routineRepository = routineRepository
        self.bodyMetricRepository = bodyMetricRepository
        self.aiInsightRepository = aiInsightRepository
        self.aiRecommender = aiRecommender

        dashboardViewModel = DashboardViewModel(workoutRepository: workoutRepository, aiInsightRepository: aiInsightRepository)
        workoutViewModel = WorkoutLoggingViewModel(logWorkoutUseCase: LogWorkoutUseCase(workoutRepository: workoutRepository), routineRepository: routineRepository)
        progressViewModel = ProgressViewModel(fetchProgressSummaryUseCase: FetchProgressSummaryUseCase(workoutRepository: workoutRepository, bodyMetricRepository: bodyMetricRepository))
        aiCoachViewModel = AICoachViewModel(generateAIInsightUseCase: GenerateAIInsightUseCase(workoutRepository: workoutRepository, bodyMetricRepository: bodyMetricRepository, recommender: aiRecommender, aiInsightRepository: aiInsightRepository))
    }
}
