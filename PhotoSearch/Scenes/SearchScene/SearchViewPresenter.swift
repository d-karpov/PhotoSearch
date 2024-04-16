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
	private var itemPointer: Int {
		(currentPage-1)*NetworkManager.itemPerPage
	}
	
	
	
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
		checkFirstSearch()
		view?.startLoading()
		NetworkManager.getImagesUrls(about: request, page: currentPage) { [weak self] photos in
			switch photos {
			case .success(let photos):
				self?.photos = photos
				self?.updateView()
			case .failure(let error):
				self?.showAlert(title: "Ошибка", with: "\(error.localizedDescription)")
			}
		}
	}
	
	func nextPage(request: String) {
		currentPage += 1
		NetworkManager.getImagesUrls(about: request, page: currentPage) { [weak self] photos in
			switch photos {
			case .success(let photos):
				let newPhotos = photos.results
				self?.photos?.results.append(contentsOf: newPhotos)
				
				let startItem = self?.itemPointer ?? 0
				let endItem = startItem + NetworkManager.itemPerPage - 1
				let indexPathsArray = Array(startItem...(endItem)).map { item in
					IndexPath(item: item, section: 0)
				}
				
				DispatchQueue.main.async {
					self?.view?.partialReload(for: indexPathsArray)
				}
			case .failure(let error):
				self?.showAlert(title: "Ошибка", with: "\(error.localizedDescription)")
			}
		}
	}
	
	func showDetail(at indexPath: IndexPath) {
		if let photo = photos?.results[indexPath.item] {
			router?.showDetailScene(of: photo)
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
					self.view?.reloadCollection()
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
