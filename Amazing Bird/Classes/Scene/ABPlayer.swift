import Foundation

@MainActor
final class ABPlayer {
    static let shared = ABPlayer()
    private init() {}

    var score: CGFloat = 0 {
        didSet {
            if Int(score) > highscore {
                highscore = Int(score)
            }
        }
    }
    private(set) var highscore: Int = 0
    var isPremium: Bool = false

    func save() {
        let defaults = UserDefaults.standard
        defaults.set(highscore, forKey: "highscore")
        defaults.set(isPremium, forKey: "premium")
    }

    func load() {
        let defaults = UserDefaults.standard
        highscore = defaults.integer(forKey: "highscore")
        isPremium = defaults.bool(forKey: "premium")
    }
}
