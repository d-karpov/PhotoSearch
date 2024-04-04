//
//  NetworkManager.swift
//  PhotoSearch
//
//  Created by Денис Карпов on 25.03.2024.
//

import Foundation


struct PhotoUrls: Codable {
	let results: [Result]
	
	struct Result: Codable {
		let urls: Url
	}
	
	struct Url: Codable {
		let thumb: URL
	}
}

struct NetworkManager {
	
	enum NetworkErrors: Error {
		case transportError(Error)
		case decoderError(Error)
		case wrongClientID
		case wrongURL
		case noData
	}
	
	static let itemPerPage = 20
	
	static func getImagesUrls(
		about request: String,
		page: Int,
		completion: @escaping(Result<PhotoUrls, NetworkErrors>) -> Void
	) {
		guard let clientID = ProcessInfo.processInfo.environment["CLIENT_ID"] else {
			return completion(.failure(.wrongClientID))
		}
		
		let apiPhotoRequest = "https://api.unsplash.com/search/photos?per_page=\(itemPerPage)&page=\(page)&client_id=\(clientID)&query="
		guard let url = URL(string: apiPhotoRequest + request.lowercased()) else {
			return completion(.failure(.wrongURL))
		}
		
		let session = URLSession.shared
		
		let task = session.dataTask(with: url) { data, _, error in
			
			if let error = error {
				return completion(.failure(.transportError(error)))
			}
			
			guard let data = data else {
				return completion(.failure(.noData))
			}
			
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
	
	static func fetchImageData(from url: URL, completion: @escaping(Result<Data, NetworkErrors>) -> Void) {
		
		let session = URLSession.shared
		let task = session.dataTask(with: url) { data, _, error in
			
			if let error = error {
				return completion(.failure(.transportError(error)))
			}
			
			guard let data = data else {
				return completion(.failure(.noData))
			}
			
			return completion(.success(data))
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
		case .wrongClientID:
			return "Не верно указан Client ID в запросе"
		}
	}
}
