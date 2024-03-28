//
//  SearchViewPresenter.swift
//  PhotoSearch
//
//  Created by Денис Карпов on 28.03.2024.
//

import Foundation

protocol ISearchViewPresenter {
	func search(request: String)
}


final class SearchViewPresenter: ISearchViewPresenter {
	
	private weak var view: ISearchView?
	
	init(view: ISearchView) {
		self.view = view
	}
	
	func search(request: String) {
		let images = fetchImages(request: request)
		let viewData = SearchViewModel.ViewData(images: images)
		view?.render(viewData: viewData)
	}
	
	private func fetchImages(request: String) -> [Data] {
		var photosData: [Data] = [Data()]
		NetworkManager.getImagesUrls(about: request) { photoUrls in
			switch photoUrls {
			case .success(let photoUrls):
				photosData = photoUrls.results.map { result in
					var data = Data()
					do {
						data = try Data(contentsOf: result.urls.regular)
					} catch {
						print("\(error.localizedDescription)")
					}
					return data
				}
			case .failure(let error):
				print("\(error.errorDescription ?? "Бесовство")")
			}
		}
		return photosData
	}
}
