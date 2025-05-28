//
//  File.swift
//  framework
//
//  Created by Алексей Румынин on 27.05.25.
//

import RxSwift
import Foundation
import UIKit

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
    
    public func downloadImage(from endpoint: Endpoint) -> Single<UIImage> {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            return .error(NetworkError.invalidURL)
        }
        
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            return .error(NetworkError.invalidURL)
        }
        
        var request: URLRequest
        
        let fullURL = endpoint.path.isEmpty ? baseURL : baseURL.appendingPathComponent(endpoint.path)

        // Уберите лишний "/" в конце URL
        if fullURL.absoluteString.hasSuffix("/") {
            let correctedURLString = String(fullURL.absoluteString.dropLast())
            guard let correctedURL = URL(string: correctedURLString) else {
                return .error(NetworkError.invalidURL)
            }
            request = URLRequest(url: correctedURL)
        } else {
            request = URLRequest(url: fullURL)
        }
        request.httpMethod = endpoint.method
        request.allHTTPHeaderFields = endpoint.headers
        
        return Single<UIImage>.create { single in
            let task = self.session.dataTask(with: request) { data, response, error in
                if let error = error {
                    single(.failure(NetworkError.unknown(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    single(.failure(NetworkError.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)))
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    single(.failure(NetworkError.decodingError))
                    return
                }
                
                single(.success(image))
            }
            
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        print("🟡 Start downloading image from URL: \(url.absoluteString)")
        contentMode = mode
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("🔴 Failed to download image: \(error.localizedDescription)")
                return
            }

            guard let httpURLResponse = response as? HTTPURLResponse else {
                print("🔴 Invalid response type")
                return
            }

            guard httpURLResponse.statusCode == 200 else {
                print("🔴 HTTP status code: \(httpURLResponse.statusCode)")
                return
            }

            guard let mimeType = response?.mimeType, mimeType.hasPrefix("image") else {
                print("🔴 Incorrect MIME type: \(String(describing: response?.mimeType))")
                return
            }

            guard let data = data else {
                print("🔴 No data received")
                return
            }

            guard let image = UIImage(data: data) else {
                print("🔴 Failed to create image from data")
                return
            }

            DispatchQueue.main.async { [weak self] in
                self?.image = image
                print("✅ Image successfully set")
            }
        }.resume()
    }

    func downloaded(from link: String, contentMode mode: ContentMode = .scaleToFill) {
        print("🔵 Trying to create URL from link: \(link)")
        guard let url = URL(string: link) else {
            print("🔴 Invalid URL string: \(link)")
            return
        }
        downloaded(from: url, contentMode: mode)
    }
}
