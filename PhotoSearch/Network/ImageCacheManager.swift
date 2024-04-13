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
	
	func getImage(photo: Photos.Result, completion: @escaping(UIImage)-> Void) {
		loadImageData(of: photo)
		imageGroup.notify(queue: .main) {
			if let image = self.checkCache(of: photo) {
				completion(image)
			}
		}
	}
	
	private func checkCache(of photo: Photos.Result) -> UIImage? {
		guard let data = cache.object(forKey: photo.id as NSString),
			  let image = UIImage(data: data as Data)
		else {
			return .none
		}
		return image
	}
	
	private func loadImageData(of photo: Photos.Result) {
		if cache.object(forKey: photo.id as NSString) == nil {
			imageGroup.enter()
			NetworkManager.fetchImageData(from: photo.urls.thumb) { [weak self] result in
				switch result {
				case .success(let data):
					self?.cache.setObject(data as NSData, forKey: photo.id as NSString)
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
