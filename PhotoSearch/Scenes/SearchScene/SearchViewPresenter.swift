//
//  SearchViewPresenter.swift
//  PhotoSearch
//
//  Created by Денис Карпов on 28.03.2024.
//

import UIKit

protocol ISearchViewPresenter {
	func viewIsReady()
	func search(request: String)
	func cellsCount() -> Int
	func prepareCell(at: IndexPath, cell: PhotoCell)
}


final class SearchViewPresenter: ISearchViewPresenter {
	
	private weak var view: ISearchView?
	
	private var images: [UIImage]
	private var firstSearch = false
	
	init(view: ISearchView) {
		self.view = view
		self.images = []
	}
	
	func viewIsReady() {
		view?.setupIU()
	}
	
	func cellsCount() -> Int {
		images.count
	}
	
	func prepareCell(at indexPath: IndexPath, cell: PhotoCell) {
		if !images.isEmpty {
			cell.configure(images[indexPath.item])
		}
	}
	
	func search(request: String) {
		checkFirstSearch()
		view?.startLoading()
		NetworkManager.getImagesUrls(about: request) { photoUrls in
			switch photoUrls {
			case .success(let photoUrls):
				let imageURL = photoUrls.results.map { result in
					result.urls.regular
				}
				ImageCacheManager.shared.getImages(urls: imageURL) { images in
					self.images = images
					self.updateView()
				}
			case .failure(let error):
				print("\(error.errorDescription ?? "Бесовство")")
			}
		}
	}
	
	private func checkFirstSearch() {
		if !firstSearch {
			view?.shiftSearchBar()
			firstSearch.toggle()
		}
	}
	
	private func updateView() {
		DispatchQueue.main.async {
			if self.images.isEmpty {
				self.view?.showNonResultLabel()
			} else {
				self.view?.showResults()
			}
		}
	}
}
