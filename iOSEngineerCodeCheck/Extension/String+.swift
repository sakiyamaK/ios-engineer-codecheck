//
//  String+.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/04.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import Foundation

extension String {
    var url: URL? {
        url(withQueryItemDic: [:])
    }
    
    func url(withQueryItemDic dic: [String: String]) -> URL? {
        guard var components = URLComponents(string: self) else {
            return nil
        }
        components.queryItems = dic.compactMap {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        return components.url
    }
}
