import Foundation

public struct BodyMetric: Identifiable, Codable, Hashable {
    public enum Kind: String, Codable, CaseIterable {
        case weight
        case bodyFat
        case chestCircumference
        case waistCircumference
        case hipCircumference
        case armCircumference
        case thighCircumference
        case calfCircumference
    }

    public let id: UUID
    public var kind: Kind
    public var value: Double
    public var unit: String
    public var date: Date
    public var note: String?

    public init(
        id: UUID = UUID(),
        kind: Kind,
        value: Double,
        unit: String,
        date: Date = .init(),
        note: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.value = value
        self.unit = unit
        self.date = date
        self.note = note
    }
}
