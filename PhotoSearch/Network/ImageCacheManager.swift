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
	
	func getImage(url: URL, completion: @escaping(UIImage)-> Void) {
		loadImageData(of: url)
		imageGroup.notify(queue: .main) {
			if let image = self.checkCache(of: url) {
				completion(image)
			}
		}
	}
	
	private func checkCache(of url: URL) -> UIImage? {
		guard let key = escapingURL(url: url.absoluteString),
			  let data = cache.object(forKey: key as NSString),
			  let image = UIImage(data: data as Data)
		else {
			return nil
		}
		return image
	}
	
	private func loadImageData(of url: URL) {
		if let key = self.escapingURL(url: url.absoluteString), cache.object(forKey: key as NSString) == nil {
			imageGroup.enter()
			NetworkManager.fetchImageData(from: url) { [weak self] result in
				switch result {
				case .success(let data):
					self?.cache.setObject(data as NSData, forKey: key as NSString)
					self?.imageGroup.leave()
				case .failure(let error):
					self?.imageGroup.leave()
					// TODO: Indication for User
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
