//
//  UIViewController+Preview.swift
//  PhotoSearch
//
//  Created by Денис Карпов on 20.03.2024.
//

import UIKit
import SwiftUI


extension UIViewController {
	struct Preview: UIViewControllerRepresentable {
	
		let viewController: UIViewController
		
		func makeUIViewController(context: Context) -> some UIViewController {
			viewController
		}
		
		func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }

	}
	
	func preview() -> some View {
		Preview(viewController: self).ignoresSafeArea(edges: .all)
	}
}
