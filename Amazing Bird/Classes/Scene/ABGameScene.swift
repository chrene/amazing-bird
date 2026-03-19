import SpriteKit

class ABGameScene: SKScene, @preconcurrency SKPhysicsContactDelegate {

    // MARK: - Constants

    private static let playerScreenFraction: CGFloat = 0.65
    private static let scoreFont = "AvenirNext-Bold"
    private static let scoreFontSize: CGFloat = 24

    private var spawnInterval: TimeInterval { isPad ? 0.12 : 0.17 }
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    // MARK: - State

    private(set) var gameStarted = false

    private var spawnCoolDown: TimeInterval = 0
    private var lastTime:      TimeInterval = 0
    private let player = ABPlayer.shared

    private var playerCharacter:      ABNormalBird!
    private var scoreLabel:           SKLabelNode!
    private var highscoreLabel:       SKLabelNode!
    private var tapToStartLabel:      SKLabelNode!
    private var worldLayers:          [SKNode] = []
    private var gameCharacters:       [ABCloud] = []
    private var endingGame            = false
    private var cameraNode:           SKCameraNode!
    private var starField:            ABStarField!
    private var scoreLabelIsScaledUp  = false
    private var displayedScore        = 0

    // MARK: - Init

    override init(size: CGSize) {
        super.init(size: size)
        spawnCoolDown = spawnInterval
        setupScene()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - Setup

    private func setupScene() {
        ABNormalBird.loadSharedFrames()

        // Camera — fixed at screen center; used only to pin HUD and background.
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
        camera = cameraNode

        // Physics
        physicsWorld.gravity = isPad ? CGVector(dx: 0, dy: -11) : CGVector(dx: 0, dy: -5.5)
        physicsWorld.contactDelegate = self

        // World layers
        for i in 0..<ABWorldLayer.count {
            let layer = SKNode()
            layer.zPosition = CGFloat(i)
            addChild(layer)
            worldLayers.append(layer)
        }

        // Background — camera child so it stays screen-fixed
        let atlas = SKTextureAtlas(named: "sprites")
        let background = SKSpriteNode(texture: atlas.textureNamed("Background"))
        background.position  = .zero
        background.size      = size
        background.zPosition = CGFloat(ABWorldLayer.background.rawValue)
        cameraNode.addChild(background)

        // Score label
        scoreLabel           = makeLabel(text: "0")
        scoreLabel.position  = CGPoint(x: 0, y: size.height * 0.6)  // off-screen initially
        cameraNode.addChild(scoreLabel)

        // Highscore label
        highscoreLabel          = makeLabel(text: "Highscore: \(player.highscore)")
        highscoreLabel.position = CGPoint(x: 0, y: -size.height * 0.25)
        cameraNode.addChild(highscoreLabel)

        // Player character
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        playerCharacter = ABNormalBird(position: center, player: player)
        playerCharacter.addToScene(self, atPosition: center)
        playerCharacter.idle()
        playerCharacter.physicsBody?.usesPreciseCollisionDetection = true

        // Cloud pool
        let maxClouds  = isPad ? 30 : 25
        gameCharacters = (0..<maxClouds).map { _ in ABCloud(position: .zero) }

        // Star field — camera child at bottom-left of camera space
        starField          = ABStarField(size: size)
        starField.position = CGPoint(x: -size.width / 2, y: -size.height / 2)
        starField.zPosition = CGFloat(ABWorldLayer.stars.rawValue)
        cameraNode.addChild(starField)

        // Tap-to-start label
        tapToStartLabel          = makeLabel(text: "Tap To Fly")
        tapToStartLabel.position = CGPoint(x: 0, y: size.height * 0.15)
        cameraNode.addChild(tapToStartLabel)
        tapToStartLabel.run(tapToStartBlinkAction())
    }

    private func makeLabel(text: String) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: ABGameScene.scoreFont)
        label.fontSize = ABGameScene.scoreFontSize
        label.text = text
        return label
    }

    private func tapToStartBlinkAction() -> SKAction {
        .repeatForever(.sequence([
            .wait(forDuration: 0.5),
            .fadeAlpha(to: 0,   duration: 0.15),
            .wait(forDuration: 0.5),
            .fadeAlpha(to: 1.0, duration: 0.15)
        ]))
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameStarted && !playerCharacter.isParalyzed {
            startGame()
        }
        if gameStarted {
            playerCharacter.move()
        }
    }

    // MARK: - Game flow

    private func startGame() {
        tapToStartLabel.removeAllActions()
        tapToStartLabel.run(.fadeAlpha(to: 0, duration: 0.5))
        gameStarted           = true
        player.score          = 0
        displayedScore        = 0
        scoreLabelIsScaledUp  = false
        highscoreLabel.isHidden = true

        let move = SKAction.move(to: CGPoint(x: 0, y: size.height * 0.4), duration: 0.5)
        move.timingMode = .easeOut
        scoreLabel.run(move)
    }

    private func endGame() {
        gameStarted           = false
        scoreLabelIsScaledUp  = false

        tapToStartLabel.removeAllActions()
        tapToStartLabel.alpha = 1.0
        tapToStartLabel.run(tapToStartBlinkAction())

        prepareForDeath()
        endingGame = false
        highscoreLabel.isHidden = false

        scoreLabel.removeAllActions()
        let move = SKAction.move(to: CGPoint(x: 0, y: -size.height * 0.15), duration: 0.8)
        move.timingMode = .easeOut
        scoreLabel.run(move)
        scoreLabel.text     = "\(Int(player.score))"
        highscoreLabel.text = "Highscore: \(player.highscore)"

        playerCharacter.revive()
    }

    private func spawnObject() {
        guard let cloud = gameCharacters.first(where: { $0.characterScene == nil }) else { return }
        gameCharacters.removeAll { $0 === cloud }
        gameCharacters.append(cloud)
        cloud.reset()
        cloud.run(.scale(to: CGFloat.random(in: 0.5...1.0), duration: 0))
        let spawnY = playerCharacter.position.y * CGFloat.random(in: 0..<3.0)
        cloud.addToScene(self, atPosition: CGPoint(x: size.width + cloud.size.width, y: spawnY))
    }

    private func prepareForDeath() {
        endingGame = true
        gameCharacters.forEach { $0.performDeath() }
    }

    // MARK: - Update

    override func update(_ currentTime: TimeInterval) {
        // Skip first frame — lastTime = 0 gives a huge delta
        if lastTime == 0 { lastTime = currentTime; return }
        let delta = currentTime - lastTime
        lastTime  = currentTime

        starField.update(delta)

        if gameStarted && !endingGame {
            spawnCoolDown -= delta
            if spawnCoolDown <= 0 {
                spawnCoolDown = spawnInterval
                spawnObject()
            }
            let currentScore = Int(player.score)
            if currentScore != displayedScore {
                displayedScore  = currentScore
                scoreLabel.text = "\(currentScore)"
            }
        }

        playerCharacter.update(delta)

        for cloud in gameCharacters {
            cloud.update(delta)
            if gameStarted, cloud.characterScene === self, !cloud.hasPassedPlayerCharacter {
                let passed = cloud.position.x + cloud.size.width / 2
                          < playerCharacter.position.x - playerCharacter.size.width / 2
                if passed {
                    cloud.hasPassedPlayerCharacter = true
                    player.score += 1
                }
            }
        }

        if playerCharacter.status == .dying && !endingGame { prepareForDeath() }
        if playerCharacter.status == .dead                 { endGame() }
    }

    // MARK: - Physics

    override func didSimulatePhysics() {
        // Camera stays fixed. Scrolling = clamp player to kPlayerScreenFraction
        // and shift all world objects down by the same offset.
        let targetY = size.height * ABGameScene.playerScreenFraction
        let offset  = playerCharacter.position.y - targetY

        if offset > 0 {
            let scoreDelta = offset / (isPad ? 8.0 : 4.0)
            player.score += scoreDelta

            playerCharacter.position.y = targetY
            for cloud in gameCharacters where cloud.characterScene != nil {
                cloud.position.y -= offset
            }

            if floor(scoreDelta) > 0 && !scoreLabelIsScaledUp {
                scoreLabel.removeAllActions()
                scoreLabel.run(.scale(to: 1.2, duration: 0.1))
                scoreLabelIsScaledUp = true
            }
        } else if scoreLabelIsScaledUp {
            scoreLabel.removeAllActions()
            scoreLabel.run(.scale(to: 1.0, duration: 0.1))
            scoreLabelIsScaledUp = false
        }
    }

    // MARK: - SKPhysicsContactDelegate

    func didBegin(_ contact: SKPhysicsContact) {
        (contact.bodyA.node as? ABGameCharacter)?.collideWith(contact.bodyB)
        (contact.bodyB.node as? ABGameCharacter)?.collideWith(contact.bodyA)
    }

    // MARK: - World layer helper

    func addNode(_ node: SKNode, atWorldLayer layer: ABWorldLayer) {
        worldLayers[layer.rawValue].addChild(node)
    }
}
