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
	func nextPage(request: String)
	func cellsCount() -> Int
	func prepareCell(at: IndexPath, cell: PhotoCell)
	func showDetail(at: IndexPath)
}

final class SearchViewPresenter: ISearchViewPresenter {
	
	private weak var view: ISearchView?
	private var router: ISearchViewRouter?
	
	private var photos: Photos?
	private var firstSearch = false
	private var currentPage: Int
	
	init(view: ISearchView, router: ISearchViewRouter) {
		self.view = view
		self.router = router
		self.photos = nil
		self.currentPage = 1
	}
	
	func viewIsReady() {
		view?.setupIU()
	}
	
	func cellsCount() -> Int {
		return photos?.results.count ?? 0
	}
	
	func prepareCell(at indexPath: IndexPath, cell: PhotoCell) {
		guard let photo = photos?.results[indexPath.item] else {
			return
		}
		ImageCacheAtDiskManager.shared.getImage(photo: photo, large: false) { [weak self] image in
			cell.configure(image)
			self?.view?.showResults()
		}
	}
	
	func search(request: String) {
		currentPage = 1
		photos = nil
		checkFirstSearch()
		view?.startLoading()
		getImages(about: request)
	}
	
	func nextPage(request: String) {
		currentPage += 1
		getImages(about: request)
	}
	
	func showDetail(at indexPath: IndexPath) {
		if let photo = photos?.results[indexPath.item] {
			router?.showDetailScene(of: photo)
		}
	}
	
	private func getImages(about: String) {
		NetworkManager.getImagesUrls(about: about, page: currentPage) { [weak self] photos in
			switch photos {
			case .success(let photos):
				if self?.photos != nil {
					let newPhotos = photos.results
					self?.photos?.results.append(contentsOf: newPhotos)
				} else {
					self?.photos = photos
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
		if let photos = self.photos {
			DispatchQueue.main.async {
				if photos.results.isEmpty {
					self.view?.showNonResultLabel()
				} else {
					self.view?.reloadCollection(with: photos.results )
				}
			}
		}
	}
	
	private func showAlert(title: String, with message: String) {
		DispatchQueue.main.async {
			self.view?.showAlert(title: title, with: message)
		}
	}
}
