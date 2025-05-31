//
//  NetworkService.swift
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
//        print("Отправляю запрос: \(request.url?.absoluteString ?? "Invalid URL")")
        
        return URLSession.shared.rx.data(request: request)
            .map { data -> T in
                let jsonString = String(data: data, encoding: .utf8) ?? "Invalid JSON"
//                print("Получен ответ: \(jsonString)")
                return try JSONDecoder().decode(T.self, from: data)
            }
    }
}

