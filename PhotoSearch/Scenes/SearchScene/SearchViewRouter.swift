//  SearchViewRouter.swift
//  PhotoSearch
//
//  Created by Денис Карпов on 30.03.2024.
//

import UIKit

protocol ISearchViewRouter: AnyObject {
	func showDetailScene(of photo: Photos.Result)
}

final class SearchViewRouter: ISearchViewRouter {
	
	private weak var view: UIViewController?
	
	init(view: UIViewController) {
		self.view = view
	}
	
	func showDetailScene(of photo: Photos.Result) {
		let detailView = DetailViewController()
		ImageCacheAtDiskManager.shared.getImage(photo: photo, large: true) { image in
			detailView.imageView.image = image
		}
		detailView.modalPresentationStyle = .pageSheet
		view?.show(detailView, sender: nil)
	}
}
