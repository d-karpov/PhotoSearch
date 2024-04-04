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
}


final class SearchViewPresenter: ISearchViewPresenter {
	
	private weak var view: ISearchView?
	
	private var imagesUrls: [URL]
	private var firstSearch = false
	private var currentPage: Int
	private var itemPointer: Int {
		(currentPage-1)*NetworkManager.itemPerPage
	}
	
	init(view: ISearchView) {
		self.view = view
		self.imagesUrls = []
		self.currentPage = 1
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
			self?.view?.showResults()
		}
	}
	
	func search(request: String) {
		currentPage = 1
		checkFirstSearch()
		view?.startLoading()
		NetworkManager.getImagesUrls(about: request, page: currentPage) { [weak self] photoUrls in
			switch photoUrls {
			case .success(let photoUrls):
				self?.imagesUrls = photoUrls.results.map { result in
					result.urls.thumb
				}
				self?.updateView()
			case .failure(let error):
				self?.showAlert(title: "Ошибка", with: "\(error.localizedDescription)")
			}
		}
	}
	
	func nextPage(request: String) {
		currentPage += 1
		NetworkManager.getImagesUrls(about: request, page: currentPage) { [weak self] photoUrls in
			switch photoUrls {
			case .success(let photoUrls):
				let newPageUrls = photoUrls.results.map { result in
					result.urls.thumb
				}
				self?.imagesUrls.append(contentsOf: newPageUrls)
				
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
