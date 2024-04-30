//
//  ImageCacheAtDiskManager.swift
//  PhotoSearch
//
//  Created by Денис Карпов on 13.04.2024.
//

import UIKit

class ImageCacheAtDiskManager {
	static let shared = ImageCacheAtDiskManager()
	
	private let manager = FileManager.default
	private let imageGroup = DispatchGroup()
	private let largePostfix = "_large"
	
	private lazy var cachesURL: URL? = {
		return manager.urls(for: .cachesDirectory, in: .userDomainMask).first
	}()
	
	private lazy var directoryURL: URL = {
		if let appCacheDirectoryURL = cachesURL?.appending(path: "PhotoSearch", directoryHint: .isDirectory) {
			do {
				try manager.createDirectory(at: appCacheDirectoryURL, withIntermediateDirectories: true)
				return appCacheDirectoryURL
			} catch let error {
				print("\(error.localizedDescription)")
			}
		}
		return manager.temporaryDirectory
		
	}()
	
	
	private init() { }
	
	func getImage(photo: Photos.Result, large: Bool, completion: @escaping(UIImage)-> Void) {
		let id = large ? photo.id + largePostfix : photo.id
		loadImageData(of: photo, large: large)
		imageGroup.notify(queue: .main) {
			if let image = self.checkCache(of: id) {
				completion(image)
			}
		}
	}
	
	private func save(data: Data, for id: String) {
		let path = directoryURL.appending(path: id)
		if !manager.fileExists(atPath: path.relativePath) {
			manager.createFile(atPath: path.relativePath, contents: data)
		}
	}
	
	private func read(from id: String) -> Data? {
		let path = directoryURL.appending(path: id)
		if manager.fileExists(atPath: path.relativePath) {
			do {
				let data = try Data(contentsOf: path)
				return data
			} catch let error {
				print(error.localizedDescription)
			}
		}
		return .none
	}
	
	private func checkCache(of id: String) -> UIImage? {
		guard let data = read(from: id),
			  let image = UIImage(data: data)
		else {
			return .none
		}
		return image
	}
	
	private func loadImageData(of photo: Photos.Result, large: Bool) {
		let id = large ? photo.id + largePostfix : photo.id
		let url = large ? photo.urls.regular : photo.urls.thumb
		let path = directoryURL.appending(path: id)
		
		if !manager.fileExists(atPath: path.relativePath) {
			imageGroup.enter()
			NetworkManager.fetchImageData(from: url) { [weak self] result in
				switch result {
				case .success(let data):
					self?.save(data: data, for: id)
					self?.imageGroup.leave()
				case .failure(let error):
					self?.imageGroup.leave()
					// TODO: Indication for User
					print(error.localizedDescription)
				}
			}
		}
	}
	
}
