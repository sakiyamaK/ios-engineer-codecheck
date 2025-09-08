//
//  SearchGithubSortType.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/08.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

enum SearchGithubSortType: String, CaseIterable {
    case stars, forks, helpWantedIssues, updated

    static var `default`: SearchGithubSortType {
        .stars
    }

    var apiParameter: String {
        switch self {
        case .helpWantedIssues:
            "help-wanted-issues"
        default:
            rawValue
        }
    }

    var text: String {
        switch self {
        case .stars:
            "スター数"
        case .forks:
            "フォーク数"
        case .helpWantedIssues:
            "HelpsWantedIssues数"
        case .updated:
            "更新日"
        }
    }
}
