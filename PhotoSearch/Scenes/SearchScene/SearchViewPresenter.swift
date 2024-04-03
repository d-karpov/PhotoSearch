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
	
	private var imagesUrls: [URL]
	private var firstSearch = false
	
	init(view: ISearchView) {
		self.view = view
		self.imagesUrls = []
	}
	
	func viewIsReady() {
		view?.setupIU()
	}
	
	func cellsCount() -> Int {
		return imagesUrls.count
	}
	
	func prepareCell(at indexPath: IndexPath, cell: PhotoCell) {
		ImageCacheManager.shared.getImage(url: imagesUrls[indexPath.item]) { [weak self] image in
			cell.configure(image)
			if indexPath.row >= 6 {
				self?.view?.showResults()
			}
		}
	}
	
	func search(request: String) {
		checkFirstSearch()
		view?.startLoading()
		NetworkManager.getImagesUrls(about: request) { [weak self] photoUrls in
			switch photoUrls {
			case .success(let photoUrls):
				self?.imagesUrls = photoUrls.results.map { result in
					result.urls.regular
				}
				self?.updateView()
			case .failure(let error):
				self?.showAlert(title: "Ошибка", with: "\(error.localizedDescription)")
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
			if self.imagesUrls.isEmpty {
				self.view?.showNonResultLabel()
			} else {
				self.view?.reloadCollection()
			}
		}
	}
	
	private func showAlert(title: String, with message: String) {
		DispatchQueue.main.async {
			self.view?.showAlert(title: title, with: message)
		}
	}
}
