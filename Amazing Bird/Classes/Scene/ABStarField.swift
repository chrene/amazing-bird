import SpriteKit

class ABStarField: SKNode {
    private let starField1: SKSpriteNode
    private let starField2: SKSpriteNode
    private var scrollInterval: TimeInterval = 0

    init(size: CGSize) {
        let atlas = SKTextureAtlas(named: "sprites")

        func makeField() -> SKSpriteNode {
            let field = SKSpriteNode()
            field.size = size
            field.anchorPoint = .zero
            for _ in 0..<50 {
                let high    = CGFloat.random(in: 0...1) > 0.5 ? CGFloat(4) : CGFloat(3)
                let starNum = Int(CGFloat.random(in: 1..<high))
                let star     = SKSpriteNode(texture: atlas.textureNamed("Star\(starNum)"))
                let posY     = CGFloat.random(in: 0...size.height)
                star.position = CGPoint(x: CGFloat.random(in: 0...size.width), y: posY)
                star.alpha    = posY / size.height
                field.addChild(star)
            }
            return field
        }

        starField1 = makeField()
        starField2 = makeField()
        super.init()
        starField1.position = .zero
        starField2.position = CGPoint(x: size.width + 1, y: 0)
        addChild(starField1)
        addChild(starField2)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    func update(_ delta: TimeInterval) {
        scrollInterval += delta
        let dx = UIScreen.main.scale * 0.5
        if scrollInterval > 0.03 {
            scrollInterval = 0
            starField1.position.x -= dx
            starField2.position.x -= dx
        }
        if starField1.position.x < -starField1.size.width {
            starField1.position.x = starField1.size.width
        } else if starField2.position.x < -starField2.size.width {
            starField2.position.x = starField2.size.width
        }
    }
}
