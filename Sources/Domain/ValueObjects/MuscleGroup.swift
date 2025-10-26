import Foundation

public enum MuscleGroup: String, CaseIterable, Codable, Hashable, Identifiable {
    case chest
    case back
    case shoulders
    case biceps
    case triceps
    case forearms
    case core
    case quadriceps
    case hamstrings
    case glutes
    case calves
    case fullBody
    case cardio
    case mobility

    public var id: String { rawValue }

    public var localizedName: String {
        switch self {
        case .chest: return "Mell"
        case .back: return "Hát"
        case .shoulders: return "Váll"
        case .biceps: return "Bicepsz"
        case .triceps: return "Tricepsz"
        case .forearms: return "Alkar"
        case .core: return "Törzs"
        case .quadriceps: return "Combfeszítő"
        case .hamstrings: return "Combhajlító"
        case .glutes: return "Farizom"
        case .calves: return "Vádli"
        case .fullBody: return "Teljes test"
        case .cardio: return "Kardió"
        case .mobility: return "Mobilitás"
        }
    }
}
