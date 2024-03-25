//
//  NetworkManager.swift
//  PhotoSearch
//
//  Created by Денис Карпов on 25.03.2024.
//

import Foundation


struct PhotoUrls: Codable {
	let results: [result]
	
	struct result: Codable {
		let urls: url
	}
	
	struct url: Codable {
		let regular: URL
	}
}

struct NetworkManager {
	
	enum NetworkErrors: Error {
		case transportError(Error)
		case decoderError(Error)
		case wrongURL
		case noData
	}
	
	static func getImagesUrls(about request: String, completion: @escaping(Result<PhotoUrls, NetworkErrors>) -> Void) {
		
		let apiPhotoRequest = "https://api.unsplash.com/search/photos?per_page=20&client_id=Ip0XA55zY7b7-d19osq1L5btGg-YCeDZVpnnJjXqHxs&query="
		guard let url = URL(string: apiPhotoRequest + request.lowercased()) else {
			return completion(.failure(.wrongURL))
		}
		
		let session = URLSession.shared
		
		let task = session.dataTask(with: url) { data, _, error in
			
			if let error = error {
				return completion(.failure(.transportError(error)))
			}
			
			guard let data = data else {
				return completion(.failure(.noData))}
			
			do {
				let decoder = JSONDecoder()
				let photoUrls = try decoder.decode(PhotoUrls.self, from: data)
				return completion(.success(photoUrls))
			} catch {
				return completion(.failure(.decoderError(error)))
			}
		}
		
		task.resume()
	}
	
}


extension NetworkManager.NetworkErrors : LocalizedError {
	var errorDescription: String? {
		switch self {
		case .transportError(let error):
			return "Сервер выдал ошибку -- \(error.localizedDescription)"
		case .decoderError(let error):
			return "Декодер выдал ошибку -- \(error.localizedDescription)"
		case .wrongURL:
			return "Ошибка в URL запроса"
		case .noData:
			return "Нет данных от сервера"
		}
	}
}
