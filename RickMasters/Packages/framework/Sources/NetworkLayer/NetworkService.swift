//
//  File.swift
//  framework
//
//  Created by Алексей Румынин on 27.05.25.
//

import RxSwift
import Foundation
import UIKit
import Network
import RxCocoa

public enum RequestType: String {
    case GET, POST
}

protocol APIRequest {
    var method: RequestType { get }
    var path: String { get }
    var parameters: [String : String] { get }
}

extension APIRequest {
    func request(with baseURL: URL) -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            fatalError("Unable to create URL components")
        }

        components.queryItems = parameters.map {
            URLQueryItem(name: String($0), value: String($1))
        }

        guard let url = components.url else {
            fatalError("Could not get url")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}

class APIClient {
    private let baseURL = URL(string: "http://test.rikmasters.ru/api/")!

    func send<T: Codable>(apiRequest: APIRequest) -> Observable<T> {
        let request = apiRequest.request(with: baseURL)
        print("Отправляю запрос: \(request.url?.absoluteString ?? "Invalid URL")")
        
        return URLSession.shared.rx.data(request: request)
            .map { data -> T in
                let jsonString = String(data: data, encoding: .utf8) ?? "Invalid JSON"
                print("Получен ответ: \(jsonString)")
                return try JSONDecoder().decode(T.self, from: data)
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

struct UsersResponse: Codable {
    let users: [User]
}

struct User: Codable, Hashable{
    let id: Int
    let sex: String
    let username: String
    let isOnline: Bool
    let age: Int
    let files: [File]
    
    init(){
        self.id = 0
        self.age = 0
        self.files = []
        self.isOnline = false
        self.username = "error"
        self.sex = "error"
    }
}

struct File: Codable , Hashable{
    let id: Int
    let url: String
    let type: String
}
