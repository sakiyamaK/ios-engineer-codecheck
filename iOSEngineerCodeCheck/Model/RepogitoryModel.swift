//
//  RepogitoryModel.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/04.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import Foundation
import SwiftData

@Model
class RepogitoryModel: Decodable {

    var id: Int
    var language: String
    var stargazersCount: Int
    var watchersCount: Int
    var forksCount: Int
    var openIssuesCount: Int
    var fullName: String
    var owner: Owner?

    enum CodingKeys: String, CodingKey {
        case id
        case language
        case stargazersCount
        case watchersCount
        case forksCount
        case openIssuesCount
        case fullName
        case owner
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        language = (try? container.decode(String.self, forKey: .language)) ?? ""
        stargazersCount = (try? container.decode(Int.self, forKey: .stargazersCount)) ?? 0
        watchersCount = (try? container.decode(Int.self, forKey: .watchersCount)) ?? 0
        forksCount = (try? container.decode(Int.self, forKey: .forksCount)) ?? 0
        openIssuesCount = (try? container.decode(Int.self, forKey: .openIssuesCount)) ?? 0
        fullName = (try? container.decode(String.self, forKey: .fullName)) ?? ""
        owner = try? container.decode(Owner.self, forKey: .owner)
    }
}

@Model
class Owner: Decodable {

    var id: Int
    private var avatarUrlStr: String?

    enum CodingKeys: String, CodingKey {
        case id
        case avatarUrlStr = "avatarUrl"
    }
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        avatarUrlStr = try? container.decode(String.self, forKey: .avatarUrlStr)
    }
}

extension Owner {
    var avatarUrl: URL? {
        avatarUrl(withQueryItemDic: [:])
    }
    func avatarUrl(withQueryItemDic dic: [String: String]) -> URL? {
        avatarUrlStr?.url(withQueryItemDic: dic)
    }
}

// MARK: - UIKit
import UIKit
extension Owner {
    func getImage() async throws -> UIImage? {
        guard let avatarUrl else {
            return nil
        }
        let (data, _) = try await URLSession.shared.data(from: avatarUrl)

        guard let image = UIImage(data: data) else {
            throw ServiceError.decodeImage
        }

        return image
    }
}

