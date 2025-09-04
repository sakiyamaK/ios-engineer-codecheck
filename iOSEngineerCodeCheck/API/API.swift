//
//  API.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/04.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import Foundation

protocol APIProtocol {
    var jsonDecoder: JSONDecoder { get }
    func searchRepogitories(q: String) async throws -> [SearchGitHubListModel]
}
extension APIProtocol {
    var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}


final class API: APIProtocol {
    static let shared = API()
    private init() {}
    
    private let host: String = "https://api.github.com"

    func searchRepogitories(q: String) async throws -> [SearchGitHubListModel] {
        guard let url = "\(host)/search/repositories".url(withQueryItemDic: ["q": q]) else {
            throw ServiceError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let dto = try jsonDecoder.decode(SearchRepogitoriesDTO.self, from: data)
        return dto.items
    }
}
