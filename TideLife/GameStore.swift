import Foundation

@MainActor
final class GameStore: ObservableObject {
    @Published var life: Life?
    @Published var showNewLife = false

    private let engine = GameEngine()
    private let saveKey = "tidelife.save.v1"

    init() {
        load()
    }

    func startNewLife(firstName: String?, gender: Gender) {
        life = engine.newLife(firstName: firstName, gender: gender)
        save()
    }

    func ageUp() {
        guard var current = life else { return }
        engine.ageUp(&current)
        life = current
        save()
    }

    func choose(_ option: DecisionOption) {
        guard var current = life else { return }
        engine.choose(option, in: &current)
        life = current
        save()
    }

    func perform(_ action: LifeAction) {
        guard var current = life else { return }
        engine.performAction(action, on: &current)
        life = current
        save()
    }

    func eraseLife() {
        life = nil
        UserDefaults.standard.removeObject(forKey: saveKey)
    }

    private func save() {
        guard let life else { return }
        do {
            let data = try JSONEncoder().encode(life)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("TideLife save failed: \(error)")
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        do {
            life = try JSONDecoder().decode(Life.self, from: data)
        } catch {
            print("TideLife load failed: \(error)")
            UserDefaults.standard.removeObject(forKey: saveKey)
        }
    }
}
