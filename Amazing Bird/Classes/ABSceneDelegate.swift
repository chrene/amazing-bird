import UIKit

class ABSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let storyboardName = UIDevice.current.userInterfaceIdiom == .pad ? "Main_iPad" : "Main_iPhone"
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let rootVC = storyboard.instantiateInitialViewController()!
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        ABPlayer.shared.load()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        ABPlayer.shared.save()
    }
}
