//
//  NetworkManager.swift
//  RestaurantApp
//
//  Created by Victor on 26.03.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

typealias requestErrorHandler = (ConnectionError) -> Void

enum ConnectionError {
	case noConnection
	case wrongUrl
	case emptyResponse
	case response(message: String)
}

protocol NetworkManagerable {
	func load<T : Modelable>(url: String, error: @escaping requestErrorHandler, success: @escaping ([T]) -> Void)
}

class NetworkManager<T : Modelable>: NetworkManagerable {
	// MARK: Properties
	private lazy var _defaultSession = { () -> URLSession in
		let configuration = URLSessionConfiguration.default
		configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
		
		return URLSession(configuration: configuration)
	}
	private var _dataTask: URLSessionDataTask?
	
	// MARK: Initialization
	func load<T : Modelable>(url: String, error: @escaping requestErrorHandler, success: @escaping ([T]) -> Void) {
		func errorOnMainThread(_ connectionError: ConnectionError) {
			DispatchQueue.main.async {
				error(connectionError)
			}
		}
		
		func successOnMainThread(_ models: [T]) {
			DispatchQueue.main.async {
				success(models)
			}
		}
		
		guard let validUrl = URL(string: url) else {
			errorOnMainThread(.wrongUrl)
			
			return
		}
		
		_dataTask?.cancel()
		_dataTask = _defaultSession().dataTask(with: validUrl) { data, response, responseError in
			defer { self._dataTask = nil }
			if let responseError = responseError {
				if let errorCode = (responseError as NSError?)?.code, errorCode == NSURLErrorNotConnectedToInternet {
					errorOnMainThread(.noConnection)
				} else {
					errorOnMainThread(.response(message: responseError.localizedDescription))
				}
				
				return
			}

			if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
				let jsonDecoder = JSONDecoder()
				jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
				if let models = try? jsonDecoder.decode([T].self, from: data) {
					successOnMainThread(models)
					
					return
				}
			}
			
			errorOnMainThread(.emptyResponse)
		}
		_dataTask!.resume()
	}
}
