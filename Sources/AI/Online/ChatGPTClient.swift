import Foundation
import Domain

public final class ChatGPTClient {
    public struct Configuration {
        public var endpoint: URL
        public var apiKey: String
        public init(endpoint: URL, apiKey: String) {
            self.endpoint = endpoint
            self.apiKey = apiKey
        }
    }

    private let configuration: Configuration
    private let urlSession: URLSession

    public init(configuration: Configuration, urlSession: URLSession = .shared) {
        self.configuration = configuration
        self.urlSession = urlSession
    }

    public func generateText(from trend: WorkoutTrend) async throws -> (motivation: String, recommendation: String) {
        var request = URLRequest(url: configuration.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        let payload: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a strength coach who responds in Hungarian."
                ],
                [
                    "role": "user",
                    "content": prompt(for: trend)
                ]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let choice = result.choices.first else { throw URLError(.cannotDecodeRawData) }
        let text = choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = text.components(separatedBy: "\n\n")
        let motivation = parts.first ?? text
        let recommendation = parts.dropFirst().joined(separator: "\n\n")
        return (motivation, recommendation)
    }

    private func prompt(for trend: WorkoutTrend) -> String {
        """
        Elemezd a következő edzésadatokat és adj motiváló visszajelzést, valamint konkrét javaslatot a progresszív túlterheléshez.
        Volume trend: \(trend.progressiveOverloadScore)
        Fatigue score: \(trend.fatigueScore)
        Izomcsoport megoszlás: \(trend.muscleBalance.map { "\($0.key.localizedName): \($0.value)" }.joined(separator: ", "))
        Pulzus átlag: \(trend.averageHeartRate)
        Pulzus csúcs: \(trend.maxHeartRate)
        Testsúly trend: \(trend.weightTrend ?? 0)
        Válaszolj strukturáltan két bekezdésben: 1) motiváció 2) ajánlás.
        """
    }
}

private struct OpenAIResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let role: String
            let content: String
        }
        let index: Int
        let message: Message
    }
    let choices: [Choice]
}
