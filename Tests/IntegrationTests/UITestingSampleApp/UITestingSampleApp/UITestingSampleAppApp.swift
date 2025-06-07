//
//  UITestingSampleAppApp.swift
//  UITestingSampleApp
//
//  Created by José Echagüe on 8/14/23.
//

import SwiftUI
import GXUIApplication

@main
final class AppDelegate: NSObject, UIApplicationDelegate {
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
		GXUIApplicationExecutionEnvironment.beginCoreInitialization()
		GXUIApplicationExecutionEnvironment.endCoreInitialization()
		return true
	}

	func application(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions
	) -> UISceneConfiguration {
		let sceneConfiguration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
		sceneConfiguration.delegateClass = SceneDelegate.self
		return sceneConfiguration
	}
}

final class SceneDelegate: NSObject, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		guard let windowScene = scene as? UIWindowScene else {
			return
		}

		let window = GXWindow(windowScene: windowScene)

		let rootView = NavigationView(content: { ContentView() })
		window.rootViewController = UIHostingController(rootView: rootView)
		window.makeKeyAndVisible()

		self.window = window
	}
}
