//
//  API.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/04.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import Foundation

protocol APIProtocol {
    static var jsonDecoder: JSONDecoder { get }
    func searchRepogitories(q: String) async throws -> [SearchGitHubListModel]
}
extension APIProtocol {
    static var jsonDecoder: JSONDecoder {
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
        let dto = try API.jsonDecoder.decode(SearchRepogitoriesDTO.self, from: data)
        return dto.items
    }
}

#if DEBUG
// MARK: - Mock Objects

final class MockAPI: APIProtocol {
    private var result: Result<[SearchGitHubListModel], Error>

    private(set) var callCount = 0
    private(set) var receivedQuery: String?

    init(result: Result<[SearchGitHubListModel], Error>) {
        self.result = result
    }

    func searchRepogitories(q: String) async throws -> [SearchGitHubListModel] {
        callCount += 1
        receivedQuery = q
        try await Task.sleep(for: .milliseconds(100))
        switch result {
        case .success(let models):
            return models
        case .failure(let error):
            throw error
        }
    }
}
#endif
