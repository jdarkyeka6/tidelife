import Foundation

struct GameEngine {
    private let firstNames = ["Jake", "Mia", "Noah", "Ava", "Luca", "Harper", "Leo", "Lily", "Ethan", "Zoe", "Jasper", "Sophie", "Hudson", "Aria"]
    private let lastNames = ["Hart", "Vale", "Rees", "Holloway", "Miller", "Nguyen", "Wilson", "Taylor", "Martin", "Chen", "Walker", "King"]
    private let cities = [
        ("Perth", "Australia"), ("Sydney", "Australia"), ("Melbourne", "Australia"),
        ("London", "United Kingdom"), ("Toronto", "Canada"), ("New York", "United States"),
        ("Tokyo", "Japan"), ("Singapore", "Singapore")
    ]

    func newLife(firstName customFirstName: String? = nil, gender: Gender = .male) -> Life {
        let first = customFirstName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? customFirstName!.trimmingCharacters(in: .whitespacesAndNewlines)
            : firstNames.randomElement()!
        let last = lastNames.randomElement()!
        let place = cities.randomElement()!

        let mother = Person(id: UUID(), name: "\(firstNames.randomElement()!) \(last)", age: Int.random(in: 24...42), relationship: "Mother", closeness: Int.random(in: 55...95), alive: true)
        let father = Person(id: UUID(), name: "\(firstNames.randomElement()!) \(last)", age: Int.random(in: 24...45), relationship: "Father", closeness: Int.random(in: 45...95), alive: true)

        let birth = LifeEvent(
            id: UUID(),
            age: 0,
            title: "Born",
            detail: "You were born in \(place.0), \(place.1).",
            symbol: "sparkles",
            createdAt: Date()
        )

        return Life(
            id: UUID(),
            firstName: first,
            lastName: last,
            gender: gender,
            city: place.0,
            country: place.1,
            age: 0,
            stage: .baby,
            alive: true,
            stats: LifeStats(
                health: Int.random(in: 70...100),
                happiness: Int.random(in: 65...100),
                smarts: Int.random(in: 35...95),
                looks: Int.random(in: 35...95),
                stress: Int.random(in: 0...10),
                reputation: 50
            ),
            money: 0,
            career: .unemployed,
            salary: 0,
            education: "None",
            relationships: [mother, father],
            timeline: [birth],
            pendingDecision: nil
        )
    }

    func ageUp(_ life: inout Life) {
        guard life.alive, life.pendingDecision == nil else { return }

        life.age += 1
        updateStage(&life)
        applyAnnualFinances(&life)
        applyNaturalStatChanges(&life)
        applyMilestones(&life)
        maybeAddRelationship(&life)
        maybeCreateDecision(&life)
        maybeCreateRandomEvent(&life)
        maybeDie(&life)
        life.stats.clamp()
    }

    func choose(_ option: DecisionOption, in life: inout Life) {
        guard life.pendingDecision != nil else { return }
        life.stats.health += option.healthDelta
        life.stats.happiness += option.happinessDelta
        life.stats.smarts += option.smartsDelta
        life.stats.stress += option.stressDelta
        life.stats.reputation += option.reputationDelta
        life.money += option.moneyDelta
        life.stats.clamp()
        addEvent(&life, title: "Decision", detail: option.resultText, symbol: "arrow.triangle.branch")
        life.pendingDecision = nil
    }

    func performAction(_ action: LifeAction, on life: inout Life) {
        guard life.alive, life.pendingDecision == nil else { return }

        switch action {
        case .study:
            life.stats.smarts += Int.random(in: 2...6)
            life.stats.stress += Int.random(in: 1...4)
            addEvent(&life, title: "Studied", detail: "You put in extra study time.", symbol: "book.fill")
        case .exercise:
            life.stats.health += Int.random(in: 2...6)
            life.stats.happiness += Int.random(in: 0...3)
            addEvent(&life, title: "Exercise", detail: "You trained and improved your fitness.", symbol: "figure.run")
        case .relax:
            life.stats.happiness += Int.random(in: 2...6)
            life.stats.stress -= Int.random(in: 3...8)
            addEvent(&life, title: "Relaxed", detail: "You took some time for yourself.", symbol: "sun.max.fill")
        case .socialise:
            life.stats.happiness += Int.random(in: 2...5)
            life.stats.reputation += Int.random(in: 1...4)
            if !life.relationships.isEmpty {
                let index = Int.random(in: life.relationships.indices)
                life.relationships[index].closeness = (life.relationships[index].closeness + Int.random(in: 3...8)).clamped(to: 0...100)
            }
            addEvent(&life, title: "Socialised", detail: "You spent time with people close to you.", symbol: "person.2.fill")
        case .partTimeJob:
            guard life.age >= 14 else { return }
            let earned = Int.random(in: 120...450)
            life.money += earned
            life.stats.stress += 2
            addEvent(&life, title: "Side job", detail: "You earned \(earned.currencyText) from a side job.", symbol: "banknote.fill")
        case .applyForJob:
            guard life.age >= 18 else { return }
            let unlocked: [Career]
            if life.stats.smarts >= 80 {
                unlocked = [.developer, .teacher, .nurse, .lawyer, .doctor, .founder, .retail]
            } else if life.stats.smarts >= 60 {
                unlocked = [.developer, .teacher, .nurse, .retail, .musician]
            } else {
                unlocked = [.retail, .musician]
            }
            let newCareer = unlocked.randomElement()!
            life.career = newCareer
            life.salary = newCareer.annualIncome
            addEvent(&life, title: "New job", detail: "You were hired as a \(newCareer.rawValue) earning \(newCareer.annualIncome.currencyText) per year.", symbol: "briefcase.fill")
        }
        life.stats.clamp()
    }

    private func updateStage(_ life: inout Life) {
        life.stage = switch life.age {
        case 0...2: .baby
        case 3...12: .child
        case 13...17: .teen
        case 18...64: .adult
        default: .senior
        }
    }

    private func applyAnnualFinances(_ life: inout Life) {
        guard life.age >= 18 else { return }
        let income = life.salary
        let baseExpenses = life.age < 25 ? 20_000 : 32_000
        let variance = Int.random(in: -4_000...8_000)
        life.money += income - max(8_000, baseExpenses + variance)
    }

    private func applyNaturalStatChanges(_ life: inout Life) {
        life.stats.happiness += Int.random(in: -4...4)
        life.stats.stress += Int.random(in: -2...3)

        if life.age > 55 {
            life.stats.health -= Int.random(in: 0...3)
        }
        if life.age > 75 {
            life.stats.health -= Int.random(in: 1...5)
        }
    }

    private func applyMilestones(_ life: inout Life) {
        switch life.age {
        case 5:
            life.education = "Primary School"
            life.career = .student
            addEvent(&life, title: "First day of school", detail: "You started primary school.", symbol: "backpack.fill")
        case 13:
            life.education = "High School"
            addEvent(&life, title: "High school", detail: "You started high school.", symbol: "building.columns.fill")
        case 16:
            if Int.random(in: 0..<100) < 55 {
                life.money += 600
                addEvent(&life, title: "First job", detail: "You picked up casual work and saved your first \(600.currencyText).", symbol: "dollarsign.circle.fill")
            }
        case 18:
            life.education = "High School Graduate"
            life.career = .unemployed
            addEvent(&life, title: "Graduation", detail: "You finished high school. Adult life begins.", symbol: "graduationcap.fill")
        case 21:
            if life.stats.smarts > 65 {
                life.education = "University Student"
                life.career = .student
                addEvent(&life, title: "University", detail: "You enrolled at university.", symbol: "graduationcap.fill")
            }
        case 24:
            if life.education == "University Student" {
                life.education = "University Degree"
                life.career = .developer
                life.salary = Career.developer.annualIncome
                addEvent(&life, title: "Degree complete", detail: "You graduated and started work as a Software Developer.", symbol: "laptopcomputer")
            }
        case 65:
            addEvent(&life, title: "Retirement age", detail: "You reached traditional retirement age.", symbol: "beach.umbrella.fill")
        default:
            break
        }
    }

    private func maybeAddRelationship(_ life: inout Life) {
        guard life.age >= 5, Int.random(in: 0..<100) < 24 else { return }
        let relation = life.age < 18 ? "Friend" : ["Friend", "Coworker", "Partner"].randomElement()!
        let person = Person(
            id: UUID(),
            name: "\(firstNames.randomElement()!) \(lastNames.randomElement()!)",
            age: max(1, life.age + Int.random(in: -3...4)),
            relationship: relation,
            closeness: Int.random(in: 35...80),
            alive: true
        )
        life.relationships.append(person)
        addEvent(&life, title: "New \(relation.lowercased())", detail: "You met \(person.name).", symbol: "person.crop.circle.badge.plus")
    }

    private func maybeCreateDecision(_ life: inout Life) {
        guard Int.random(in: 0..<100) < 26 else { return }

        let decisions: [PendingDecision]
        if life.age < 13 {
            decisions = [
                PendingDecision(id: UUID(), title: "School trouble", detail: "A classmate is being picked on. What do you do?", options: [
                    DecisionOption(id: UUID(), title: "Stand up for them", resultText: "You stepped in. It was scary, but people remembered it.", healthDelta: 0, happinessDelta: 3, smartsDelta: 0, stressDelta: 3, reputationDelta: 8, moneyDelta: 0),
                    DecisionOption(id: UUID(), title: "Stay out of it", resultText: "You kept walking and avoided the drama.", healthDelta: 0, happinessDelta: -2, smartsDelta: 0, stressDelta: -1, reputationDelta: -2, moneyDelta: 0)
                ])
            ]
        } else if life.age < 18 {
            decisions = [
                PendingDecision(id: UUID(), title: "Big exam tomorrow", detail: "Your friends invite you out the night before an important exam.", options: [
                    DecisionOption(id: UUID(), title: "Study", resultText: "You stayed home, studied, and absolutely cooked the exam.", healthDelta: 0, happinessDelta: -2, smartsDelta: 7, stressDelta: 3, reputationDelta: 0, moneyDelta: 0),
                    DecisionOption(id: UUID(), title: "Go out", resultText: "You went out with your friends. Great night. Questionable academic strategy.", healthDelta: -1, happinessDelta: 7, smartsDelta: -4, stressDelta: -2, reputationDelta: 3, moneyDelta: -30)
                ])
            ]
        } else {
            decisions = [
                PendingDecision(id: UUID(), title: "Risky opportunity", detail: "A friend wants you to put money into their new business.", options: [
                    DecisionOption(id: UUID(), title: "Invest $2,000", resultText: "You took the risk. The investment paid back more than you expected.", healthDelta: 0, happinessDelta: 4, smartsDelta: 2, stressDelta: 4, reputationDelta: 2, moneyDelta: 3_500),
                    DecisionOption(id: UUID(), title: "Pass", resultText: "You kept your money and watched from the sidelines.", healthDelta: 0, happinessDelta: 0, smartsDelta: 0, stressDelta: -1, reputationDelta: 0, moneyDelta: 0)
                ]),
                PendingDecision(id: UUID(), title: "Career crossroads", detail: "Your boss offers you a promotion with more money and much more pressure.", options: [
                    DecisionOption(id: UUID(), title: "Take promotion", resultText: "You accepted the promotion and your income jumped.", healthDelta: -1, happinessDelta: 2, smartsDelta: 1, stressDelta: 9, reputationDelta: 5, moneyDelta: 8_000),
                    DecisionOption(id: UUID(), title: "Keep balance", resultText: "You declined and protected your free time.", healthDelta: 2, happinessDelta: 4, smartsDelta: 0, stressDelta: -7, reputationDelta: -1, moneyDelta: 0)
                ])
            ]
        }

        life.pendingDecision = decisions.randomElement()
    }

    private func maybeCreateRandomEvent(_ life: inout Life) {
        guard Int.random(in: 0..<100) < 42 else { return }

        let eventRoll = Int.random(in: 0..<6)
        switch eventRoll {
        case 0:
            life.stats.happiness += 5
            addEvent(&life, title: "Great year", detail: "Things just seemed to click this year.", symbol: "star.fill")
        case 1:
            let cost = life.age >= 18 ? Int.random(in: 200...2_500) : 0
            life.money -= cost
            life.stats.stress += 4
            addEvent(&life, title: "Unexpected problem", detail: cost > 0 ? "A surprise expense cost you \(cost.currencyText)." : "A frustrating problem made the year harder.", symbol: "exclamationmark.triangle.fill")
        case 2:
            life.stats.health += 4
            addEvent(&life, title: "Healthy streak", detail: "You felt unusually healthy and energetic.", symbol: "heart.fill")
        case 3:
            life.stats.smarts += 3
            addEvent(&life, title: "New obsession", detail: "You got deeply interested in something new and learned a lot.", symbol: "lightbulb.fill")
        case 4:
            if life.age >= 18 {
                let bonus = Int.random(in: 500...8_000)
                life.money += bonus
                addEvent(&life, title: "Lucky break", detail: "You unexpectedly made \(bonus.currencyText).", symbol: "banknote.fill")
            }
        default:
            life.stats.reputation += Int.random(in: -3...5)
            addEvent(&life, title: "People talked", detail: "Something you did changed how people see you.", symbol: "bubble.left.and.bubble.right.fill")
        }
    }

    private func maybeDie(_ life: inout Life) {
        let ageRisk: Int
        switch life.age {
        case ..<60: ageRisk = 0
        case 60..<70: ageRisk = 1
        case 70..<80: ageRisk = 3
        case 80..<90: ageRisk = 9
        case 90..<100: ageRisk = 22
        default: ageRisk = 50
        }

        let healthRisk = max(0, 45 - life.stats.health) / 4
        if life.stats.health <= 0 || Int.random(in: 0..<100) < ageRisk + healthRisk {
            life.alive = false
            life.stage = .deceased
            life.career = .unemployed
            life.salary = 0
            addEvent(&life, title: "Life complete", detail: "\(life.fullName) died at age \(life.age) with a net worth of \(life.money.currencyText).", symbol: "moon.stars.fill")
        }
    }

    private func addEvent(_ life: inout Life, title: String, detail: String, symbol: String) {
        life.timeline.insert(
            LifeEvent(id: UUID(), age: life.age, title: title, detail: detail, symbol: symbol, createdAt: Date()),
            at: 0
        )
    }
}

enum LifeAction: String, CaseIterable, Identifiable {
    case study = "Study"
    case exercise = "Exercise"
    case relax = "Relax"
    case socialise = "Socialise"
    case partTimeJob = "Side Job"
    case applyForJob = "Find Job"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .study: "book.fill"
        case .exercise: "figure.run"
        case .relax: "sun.max.fill"
        case .socialise: "person.2.fill"
        case .partTimeJob: "banknote.fill"
        case .applyForJob: "briefcase.fill"
        }
    }
}
