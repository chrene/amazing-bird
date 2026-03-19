import UIKit
import SpriteKit

class ABViewController: UIViewController {
    private var runningScene: ABGameScene?

    override var prefersStatusBarHidden: Bool { true }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let skView = view as? SKView, skView.scene == nil else { return }
        let scene = ABGameScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        runningScene = scene
    }

    override var shouldAutorotate: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let scene = runningScene, scene.gameStarted,
           let orientation = view.window?.windowScene?.interfaceOrientation {
            return UIInterfaceOrientationMask(rawValue: 1 << orientation.rawValue)
        }
        return UIDevice.current.userInterfaceIdiom == .phone ? .allButUpsideDown : .all
    }
}
