//
//  SearchViewRouter.swift
//  PhotoSearch
//
//  Created by Денис Карпов on 30.03.2024.
//

import UIKit

protocol ISearchViewRouter: AnyObject {
	func showDetailScene(of image: UIImage)
}

final class SearchViewRouter: ISearchViewRouter {
	
	private weak var view: UIViewController?
	
	init(view: UIViewController) {
		self.view = view
	}

	func showDetailScene(of image: UIImage) {
		let detailView = DetailViewController()
		detailView.imageView.image = image
		detailView.modalPresentationStyle = .pageSheet
		view?.show(detailView, sender: nil)
	}
}

