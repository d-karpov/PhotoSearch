//
//  ImageCacheManager.swift
//  PhotoSearch
//
//  Created by Денис Карпов on 30.03.2024.
//

import UIKit


final class ImageCacheManager {
	private init() { }
	
	static var shared = ImageCacheManager()
	
	private let cache = NSCache<NSString, NSData>()
	private let imageGroup = DispatchGroup()
	private let largePostfix = "large"
	
	func getImage(photo: Photos.Result, large: Bool, completion: @escaping(UIImage)-> Void) {
		let id = large ? photo.id + largePostfix : photo.id
		loadImageData(of: photo, large: large)
		imageGroup.notify(queue: .main) {
			if let image = self.checkCache(of: id) {
				completion(image)
			}
		}
	}
	
	private func checkCache(of id: String) -> UIImage? {
		guard let data = cache.object(forKey: id as NSString),
			  let image = UIImage(data: data as Data)
		else {
			return .none
		}
		return image
	}
	
	private func loadImageData(of photo: Photos.Result, large: Bool) {
		let id = large ? photo.id + largePostfix : photo.id
		let url = large ? photo.urls.regular : photo.urls.thumb
		if cache.object(forKey: id as NSString) == nil {
			imageGroup.enter()
			NetworkManager.fetchImageData(from: url) { [weak self] result in
				switch result {
				case .success(let data):
					self?.cache.setObject(data as NSData, forKey: id as NSString)
					self?.imageGroup.leave()
				case .failure(let error):
					self?.imageGroup.leave()
					// TODO: Indication for User
					print("\(error.localizedDescription)")
				}
			}
		}
	}
}
