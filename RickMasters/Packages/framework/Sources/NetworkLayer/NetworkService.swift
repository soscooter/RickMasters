//
//  File.swift
//  framework
//
//  Created by Алексей Румынин on 27.05.25.
//

import RxSwift
import Foundation

public enum NetworkError: Error {
    case invalidURL
    case decodingError
    case httpError(Int)
    case unknown(Error)
}

public protocol Endpoint {
    var path: String { get }
    var method: String { get } // "GET", "POST", etc.
    var queryItems: [URLQueryItem]? { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}

public final class NetworkService {
    private let baseURL: URL
    private let session: URLSession
    
    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    public func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) -> Single<T> {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            return .error(NetworkError.invalidURL)
        }
        
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            return .error(NetworkError.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.httpBody = endpoint.body
        request.allHTTPHeaderFields = endpoint.headers
        
        return Single<T>.create { single in
            let task = self.session.dataTask(with: request) { data, response, error in
                if let error = error {
                    single(.failure(NetworkError.unknown(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    single(.failure(NetworkError.invalidURL))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    single(.failure(NetworkError.httpError(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    single(.failure(NetworkError.invalidURL))
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    single(.success(decoded))
                } catch {
                    single(.failure(NetworkError.decodingError))
                }
            }
            
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
