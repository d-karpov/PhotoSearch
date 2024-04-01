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
	
	private var imageCache: [String : Data] = [:]
	private let imageGroup = DispatchGroup()
	
	func getImages(urls: [URL], completion: @escaping([UIImage]) -> Void) {
		var images: [UIImage] = []
		urls.forEach { url in
			loadImageData(of: url)
		}
		imageGroup.notify(queue: .global()) {
			urls.forEach { url in
				if let image = self.checkCache(of: url) {
					images.append(image)
				}
			}
			completion(images)
		}
	}
	
	private func checkCache(of url: URL) -> UIImage? {
		guard let key = escapingURL(url: url.absoluteString),
			  let data = imageCache[key],
			  let image = UIImage(data: data)
		else {
			loadImageData(of: url)
			return nil
		}
		return image
	}
	
	private func loadImageData(of url: URL) {
		if let key = self.escapingURL(url: url.absoluteString), imageCache[key] == nil {
			imageGroup.enter()
			NetworkManager.fetchImageData(from: url) { result in
				switch result {
				case .success(let data):
					self.imageCache[key] = data
					self.imageGroup.leave()
				case .failure(let error):
					print("\(error.localizedDescription)")
				}
			}
		}
	}
	
	private func escapingURL(url: String) -> String? {
		var allowedPathParamAndKey = NSCharacterSet.urlPathAllowed
		allowedPathParamAndKey.remove(charactersIn: ";/?:@&=+$, ")
		return url.addingPercentEncoding(withAllowedCharacters: allowedPathParamAndKey)
	}
	
}
