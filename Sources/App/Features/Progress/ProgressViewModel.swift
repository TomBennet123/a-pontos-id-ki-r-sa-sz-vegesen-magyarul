import Foundation
import Domain

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published private(set) var summary: ProgressSummary?
    @Published private(set) var isLoading = false

    private let fetchProgressSummaryUseCase: FetchProgressSummaryUseCase

    init(fetchProgressSummaryUseCase: FetchProgressSummaryUseCase) {
        self.fetchProgressSummaryUseCase = fetchProgressSummaryUseCase
    }

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let now = Date()
            let interval = DateInterval(start: Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now, end: now)
            summary = try await fetchProgressSummaryUseCase.execute(for: interval)
        } catch {
            print("Progress refresh failed: \(error)")
        }
    }
}
