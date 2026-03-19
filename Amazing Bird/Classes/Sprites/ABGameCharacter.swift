import SpriteKit

// MARK: - Enums

enum ABGameCharacterStatus {
    case idle, moving, dying, dead, reviving

    var isParalyzed: Bool {
        self == .dying || self == .dead || self == .reviving
    }
}

struct ABColliderType {
    static let bird:  UInt32 = 1
    static let cloud: UInt32 = 2
}

enum ABWorldLayer: Int {
    case background = 0
    case stars
    case gameCharacters
    case foreground

    static let count = 4
}

// MARK: - ABGameCharacter

class ABGameCharacter: SKSpriteNode {
    var hitPoints = 0
    var maxHitPoints = 0
    var movementSpeed: CGFloat = 0
    var status: ABGameCharacterStatus = .idle
    private(set) var activeAnimationKey: String?

    init(texture: SKTexture, position: CGPoint) {
        super.init(texture: texture, color: .clear, size: texture.size())
        self.position = position
        configurePhysicsBody()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - Overridable

    func configurePhysicsBody() {}
    func collideWith(_ body: SKPhysicsBody) {}

    func reset() {
        removeAllActions()
        alpha = 1
    }

    @discardableResult
    func applyDamage(_ damage: Int) -> Bool {
        hitPoints = max(0, hitPoints - damage)
        return hitPoints == 0
    }

    func idle() {}
    func move() {}
    func performDeath() {}
    func revive() {}
    func update(_ delta: TimeInterval) {}

    class func loadSharedFrames() {}

    // MARK: - Animation

    func animateWithFrames(_ frames: [SKTexture], interval: TimeInterval, key: String) {
        removeAction(forKey: activeAnimationKey ?? "")
        let animate = SKAction.animate(with: frames, timePerFrame: interval)
        let notify  = SKAction.run { [weak self] in self?.completedAnimation(key: key) }
        run(SKAction.sequence([animate, notify]), withKey: key)
        activeAnimationKey = key
    }

    func completedAnimation(key: String) {}

    // MARK: - Scene

    func addToScene(_ scene: ABGameScene, atPosition position: CGPoint) {
        scene.addNode(self, atWorldLayer: .gameCharacters)
        self.position = position
    }

    var characterScene: ABGameScene? { scene as? ABGameScene }
}
