//
//  File.swift
//  framework
//
//  Created by Алексей Румынин on 27.05.25.
//

import Foundation

class StatisticService{
    func fetchUsers(){
        
        let service = NetworkService(baseURL: URL(string: "http://test.rikmasters.ru/api/")!)
        let endpoint = UsersEndpoint()
        
        let disposable = service.request(endpoint, responseType: UsersResponse.self)
            .subscribe(onSuccess: { users in
                print("Received users:", users)
            }, onFailure: { error in
                print("Error:", error)
            })
    }
}
struct UsersEndpoint: Endpoint {
    public let path = "users/"
    public let method = "GET"
    public let queryItems: [URLQueryItem]? = nil
    public let headers: [String: String]? = nil
    public let body: Data? = nil
    
    public init() {}
}
struct UsersResponse: Decodable {
    let users: [User]
}

struct User: Decodable{
    let id: Int
    let sex: String
    let username: String
    let isOnline: Bool
    let age: Int
    let files: [File]
}

struct File: Decodable{
    let id: Int
    let url: String
    let type: String
}

