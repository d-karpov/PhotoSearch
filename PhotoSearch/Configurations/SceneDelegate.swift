//
//  SceneDelegate.swift
//  PhotoSearch
//
//  Created by Денис Карпов on 20.03.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	
	var window: UIWindow?
	
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		
		guard let scene = (scene as? UIWindowScene) else { return }
		
		let window = UIWindow(windowScene: scene)
		window.rootViewController = assemblySearchView()
		window.makeKeyAndVisible()
		self.window = window
	}
	
	// MARK: - Private methods
	private func assemblySearchView() -> UIViewController {
		SearchViewController()
	}
}
