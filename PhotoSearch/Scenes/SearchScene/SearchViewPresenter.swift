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
	
	private var images: [Data]
	private var firstSearch = false
	
	init(view: ISearchView) {
		self.view = view
		self.images = [Data()]
	}
	
	func viewIsReady() {
		view?.setupIU()
	}
	
	func cellsCount() -> Int {
		images.count
	}
	
	func prepareCell(at indexPath: IndexPath, cell: PhotoCell) {
		if !images.isEmpty, let image = UIImage(data: images[indexPath.item]) {
			cell.configure(image)
		}
	}
	
	func search(request: String) {
		checkFirstSearch()
		view?.startLoading()
		NetworkManager.getImagesUrls(about: request) { photoUrls in
			switch photoUrls {
			case .success(let photoUrls):
		
				self.images = photoUrls.results.map { result in
					var data = Data()
					do {
						data = try Data(contentsOf: result.urls.regular)
					} catch {
						print("\(error.localizedDescription)")
					}
					return data
				}
				
				DispatchQueue.main.async {
					if self.images.isEmpty {
						self.view?.showNonResultLabel()
					} else {
						self.view?.showResults()
					}
			
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

}
