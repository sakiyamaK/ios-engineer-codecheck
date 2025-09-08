//
//  ProcessInfoForUITest.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/08.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import Foundation

public enum ProcessInfoForUITest: String, CaseIterable {
    case searchGitHubList
    case SearchGitHubDetail

    static let infoKey = "-UITest-"
    public var key: String {
        ProcessInfoForUITest.infoKey + rawValue
    }
}
