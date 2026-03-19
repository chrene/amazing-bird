import SpriteKit

class ABCloud: ABGameCharacter {
    private static let isPad = UIDevice.current.userInterfaceIdiom == .pad

    private var collidedWithCloud = false
    var hasPassedPlayerCharacter = false

    // MARK: - Init

    init(position: CGPoint) {
        let texture = SKTextureAtlas(named: "sprites").textureNamed("Cloud")
        super.init(texture: texture, position: position)
        name = "cloud"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - Physics

    override func configurePhysicsBody() {
        let offsetX = size.width  * anchorPoint.x
        let offsetY = size.height * anchorPoint.y

        let path = CGMutablePath()
        if ABCloud.isPad {
            path.move(to:    CGPoint(x:  17 - offsetX, y: 85 - offsetY))
            path.addLine(to: CGPoint(x: 128 - offsetX, y: 91 - offsetY))
            path.addLine(to: CGPoint(x: 147 - offsetX, y: 29 - offsetY))
            path.addLine(to: CGPoint(x: 101 - offsetX, y:  2 - offsetY))
            path.addLine(to: CGPoint(x:   6 - offsetX, y: 21 - offsetY))
        } else {
            path.move(to:    CGPoint(x:  4 - offsetX, y: 45 - offsetY))
            path.addLine(to: CGPoint(x: 70 - offsetX, y: 53 - offsetY))
            path.addLine(to: CGPoint(x: 83 - offsetX, y: 14 - offsetY))
            path.addLine(to: CGPoint(x: 46 - offsetX, y:  1 - offsetY))
            path.addLine(to: CGPoint(x:  2 - offsetX, y: 14 - offsetY))
        }
        path.closeSubpath()

        physicsBody = SKPhysicsBody(polygonFrom: path)
        physicsBody?.affectedByGravity  = false
        physicsBody?.linearDamping      = 0
        physicsBody?.allowsRotation     = false
        physicsBody?.mass               = 1e1
        physicsBody?.categoryBitMask    = ABColliderType.cloud
        physicsBody?.collisionBitMask   = ABColliderType.bird
        physicsBody?.contactTestBitMask = ABColliderType.bird | ABColliderType.cloud
    }

    // MARK: - Pool reset

    override func reset() {
        super.reset()
        collidedWithCloud = false
        hasPassedPlayerCharacter = false
    }

    // MARK: - Movement

    private func startMoving() {
        let speed = ABCloud.isPad
            ? CGFloat.random(in: 520...650)
            : CGFloat.random(in: 260...350)
        physicsBody?.velocity = CGVector(dx: -speed, dy: 0)
    }

    override func addToScene(_ scene: ABGameScene, atPosition position: CGPoint) {
        super.addToScene(scene, atPosition: position)
        startMoving()
    }

    // MARK: - Update / collision

    override func update(_ delta: TimeInterval) {
        if position.x + size.width / 2 < 0 || position.y + size.height / 2 < 0 {
            removeFromParent()
        }
    }

    override func collideWith(_ body: SKPhysicsBody) {
        if body.categoryBitMask == ABColliderType.bird {
            (body.node as? ABNormalBird)?.applyDamage(1)
        } else if body.categoryBitMask == ABColliderType.cloud, !collidedWithCloud {
            run(SKAction.fadeAlpha(to: CGFloat.random(in: 0.3...0.9), duration: 1))
            collidedWithCloud = true
        }
    }

    // MARK: - Death

    override func performDeath() {
        status = .dying
        run(SKAction.fadeAlpha(to: 0, duration: 0.2)) { [weak self] in
            self?.removeFromParent()
            self?.status = .dead
        }
    }
}
