import SpriteKit

class ABNormalBird: ABGameCharacter {
    private weak var player: ABPlayer?

    private static var sharedFrames: [SKTexture] = []
    private static let isPad = UIDevice.current.userInterfaceIdiom == .pad

    var isParalyzed: Bool { status.isParalyzed }

    // MARK: - Init

    init(position: CGPoint, player: ABPlayer) {
        let texture = SKTextureAtlas(named: "bird_anim").textureNamed("bird_anim0")
        super.init(texture: texture, position: position)
        self.player = player
        hitPoints = 1
        maxHitPoints = 3
        movementSpeed = 7
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - Physics

    override func configurePhysicsBody() {
        let offsetX = size.width  * anchorPoint.x
        let offsetY = size.height * anchorPoint.y

        let path = CGMutablePath()
        if ABNormalBird.isPad {
            path.move(to:    CGPoint(x:  4 - offsetX, y: 19 - offsetY))
            path.addLine(to: CGPoint(x: 36 - offsetX, y: 29 - offsetY))
            path.addLine(to: CGPoint(x: 54 - offsetX, y: 22 - offsetY))
            path.addLine(to: CGPoint(x: 37 - offsetX, y:  2 - offsetY))
            path.addLine(to: CGPoint(x: 10 - offsetX, y:  4 - offsetY))
        } else {
            path.move(to:    CGPoint(x:  3 - offsetX, y:  9 - offsetY))
            path.addLine(to: CGPoint(x: 18 - offsetX, y: 14 - offsetY))
            path.addLine(to: CGPoint(x: 25 - offsetX, y: 11 - offsetY))
            path.addLine(to: CGPoint(x: 18 - offsetX, y:  1 - offsetY))
            path.addLine(to: CGPoint(x:  4 - offsetX, y:  3 - offsetY))
            path.addLine(to: CGPoint(x:  1 - offsetX, y:  9 - offsetY))
        }
        path.closeSubpath()

        physicsBody = SKPhysicsBody(polygonFrom: path)
        physicsBody?.isDynamic = false
        physicsBody?.mass = 0.01
        reset()
    }

    // MARK: - Actions

    override func idle() {
        super.idle()
        status = .idle
        physicsBody?.isDynamic = false
        animateWithFrames(ABNormalBird.sharedFrames, interval: 1.0 / 32.0, key: "animIdleKey")
        guard action(forKey: "idleMovementKey") == nil else { return }
        let bob = SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: -7, duration: 1),
            SKAction.moveBy(x: 0, y:  7, duration: 1)
        ]))
        run(bob, withKey: "idleMovementKey")
    }

    override func move() {
        guard !isParalyzed else { return }
        status = .moving
        physicsBody?.isDynamic = true
        physicsBody?.velocity = .zero
        let impulse = ABNormalBird.isPad ? CGVector(dx: 0, dy: 7.0) : CGVector(dx: 0, dy: 3.5)
        physicsBody?.applyImpulse(impulse)
        animateWithFrames(ABNormalBird.sharedFrames, interval: 1.0 / 45.0, key: "animMoveKey")
    }

    override func performDeath() {
        status = .dying
        physicsBody?.collisionBitMask  = 0
        physicsBody?.contactTestBitMask = 0
    }

    override func reset() {
        physicsBody?.categoryBitMask    = ABColliderType.bird
        physicsBody?.contactTestBitMask = ABColliderType.cloud
        physicsBody?.collisionBitMask   = ABColliderType.cloud
        physicsBody?.allowsRotation     = true
    }

    override func revive() {
        guard status != .reviving, let scene = characterScene else { return }
        status = .reviving
        run(SKAction.move(to: CGPoint(x: scene.size.width / 2, y: position.y), duration: 0))
        zRotation = 0
        physicsBody?.isDynamic = false

        let center    = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        let moveUp    = SKAction.move(to: center, duration: 0.7)
        moveUp.timingMode = .easeIn
        let rotate    = SKAction.rotate(byAngle: .pi * 2, duration: 0.7)
        let reviveSeq = SKAction.sequence([
            .wait(forDuration: 0.5),
            .group([moveUp, rotate])
        ])
        run(reviveSeq) { [weak self] in
            self?.idle()
            self?.reset()
        }
    }

    override func update(_ delta: TimeInterval) {
        guard status != .reviving else { return }
        if position.y + size.height < 0 {
            status = .dead
        }
    }

    // MARK: - Damage

    @discardableResult
    override func applyDamage(_ damage: Int) -> Bool {
        let dead = super.applyDamage(damage)
        if dead { performDeath() }
        return dead
    }

    // MARK: - Animation callbacks

    override func completedAnimation(key: String) {
        if key == "animIdleKey" { idle() }
    }

    // MARK: - Scene

    override func addToScene(_ scene: ABGameScene, atPosition position: CGPoint) {
        scene.addNode(self, atWorldLayer: .gameCharacters)
        self.position = CGPoint(x: scene.size.width / 2, y: -100)
        revive()
    }

    // MARK: - Shared frames

    override static func loadSharedFrames() {
        guard sharedFrames.isEmpty else { return }
        let atlas = SKTextureAtlas(named: "bird_anim")
        let count = atlas.textureNames.count / 4
        sharedFrames = (0..<count).map { atlas.textureNamed("bird_anim\($0).png") }
    }
}
