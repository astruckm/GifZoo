//
//  NetworkRequest.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 2/13/21.
//

import Foundation


protocol NetworkRequest: AnyObject {
    associatedtype ModelType
    func load(_ url: URL, withCompletion completion: @escaping (Result<ModelType, Error>) -> ())
    func decode(_ data: Data) -> ModelType?
}

extension NetworkRequest {
    func load(_ url: URL, withCompletion completion: @escaping (Result<ModelType, Error>) -> ()) {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkingErrors.noData))
                return
            }
            if let successfulResult = self.decode(data) {
                completion(.success(successfulResult))
            } else {
                completion(.failure(NetworkingErrors.dataDecodingFailure))
            }
        }
        task.resume()
    }
}
