import Foundation

enum Gender: String, Codable, CaseIterable, Identifiable {
    case female = "Female"
    case male = "Male"
    case nonBinary = "Non-binary"

    var id: String { rawValue }
}

enum LifeStage: String, Codable {
    case baby, child, teen, adult, senior, deceased
}

enum Career: String, Codable, CaseIterable {
    case unemployed = "Unemployed"
    case student = "Student"
    case retail = "Retail Worker"
    case teacher = "Teacher"
    case developer = "Software Developer"
    case nurse = "Nurse"
    case lawyer = "Lawyer"
    case doctor = "Doctor"
    case athlete = "Professional Athlete"
    case musician = "Musician"
    case founder = "Founder / CEO"

    var annualIncome: Int {
        switch self {
        case .unemployed, .student: 0
        case .retail: 42_000
        case .teacher: 78_000
        case .developer: 120_000
        case .nurse: 92_000
        case .lawyer: 155_000
        case .doctor: 220_000
        case .athlete: 350_000
        case .musician: 110_000
        case .founder: 180_000
        }
    }
}

struct LifeStats: Codable {
    var health: Int
    var happiness: Int
    var smarts: Int
    var looks: Int
    var stress: Int
    var reputation: Int

    mutating func clamp() {
        health = health.clamped(to: 0...100)
        happiness = happiness.clamped(to: 0...100)
        smarts = smarts.clamped(to: 0...100)
        looks = looks.clamped(to: 0...100)
        stress = stress.clamped(to: 0...100)
        reputation = reputation.clamped(to: 0...100)
    }
}

struct Person: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var age: Int
    var relationship: String
    var closeness: Int
    var alive: Bool
}

struct LifeEvent: Identifiable, Codable {
    let id: UUID
    let age: Int
    let title: String
    let detail: String
    let symbol: String
    let createdAt: Date
}

struct PendingDecision: Identifiable, Codable {
    let id: UUID
    let title: String
    let detail: String
    let options: [DecisionOption]
}

struct DecisionOption: Identifiable, Codable {
    let id: UUID
    let title: String
    let resultText: String
    let healthDelta: Int
    let happinessDelta: Int
    let smartsDelta: Int
    let stressDelta: Int
    let reputationDelta: Int
    let moneyDelta: Int
}

struct Life: Codable {
    var id: UUID
    var firstName: String
    var lastName: String
    var gender: Gender
    var city: String
    var country: String
    var age: Int
    var stage: LifeStage
    var alive: Bool
    var stats: LifeStats
    var money: Int
    var career: Career
    var salary: Int
    var education: String
    var relationships: [Person]
    var timeline: [LifeEvent]
    var pendingDecision: PendingDecision?

    var fullName: String { "\(firstName) \(lastName)" }
    var location: String { "\(city), \(country)" }
    var netWorthText: String { money.currencyText }
}

extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }

    var currencyText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "$\(self)"
    }
}
