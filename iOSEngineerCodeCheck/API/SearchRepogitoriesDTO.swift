//
//  Untitled.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/04.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import Foundation

struct SearchRepogitoriesDTO: Decodable {
    var items: [SearchGitHubDetailModel]
}


#if DEBUG

// MARK: - Test Data

extension SearchRepogitoriesDTO {
    static var mockSuccess: SearchRepogitoriesDTO {
        let mockSuccessJSON = """
        {
            "items": [
              {
                "id": 1,
                "full_name": "apple/swift",
                "language": "C++",
                "stargazers_count": 60000,
                "watchers_count": 7000,
                "forks_count": 9000,
                "open_issues_count": 600,
                "owner": {
                  "id": 10639145,
                  "avatar_url": "https://avatars.githubusercontent.com/u/10639145?v=4"
                }
              }
            ]
        }
        """.data(using: .utf8)!
        return try! API.jsonDecoder.decode(SearchRepogitoriesDTO.self, from: mockSuccessJSON)
    }
}

#endif
