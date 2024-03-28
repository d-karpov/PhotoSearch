//
//  SearchViewPresenter.swift
//  PhotoSearch
//
//  Created by Денис Карпов on 28.03.2024.
//

import Foundation

protocol ISearchViewPresenter {
	func viewIsReady()
	func search(request: String)
}


final class SearchViewPresenter: ISearchViewPresenter {
	
	private weak var view: ISearchView?
	
	init(view: ISearchView) {
		self.view = view
	}
	
	func viewIsReady() {
		view?.render(viewData: SearchViewModel.ViewData(images: [Data()], cellsCount: 0))
	}
	
	func search(request: String) {
		viewIsReady()
		NetworkManager.getImagesUrls(about: request) { photoUrls in
			switch photoUrls {
			case .success(let photoUrls):
				DispatchQueue.main.async {
					let images = photoUrls.results.map { result in
						var data = Data()
						do {
							data = try Data(contentsOf: result.urls.regular)
						} catch {
							print("\(error.localizedDescription)")
						}
						return data
					}
					let viewData = SearchViewModel.ViewData(images: images, cellsCount: images.count)
					self.view?.render(viewData: viewData)
				}
			case .failure(let error):
				print("\(error.errorDescription ?? "Бесовство")")
			}
		}
	}

}
