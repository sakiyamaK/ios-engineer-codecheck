//
//  NetworkError.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/04.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import Foundation

enum ServiceError: Error {
    case network, decodeImage, invalidURL, unknown

    var localizedDescription: String {
        switch self {
        case .network:
            return "Network Error"
        case .decodeImage:
            return "Decode Image Error"
        case .invalidURL:
            return "Invalid URL"
        case .unknown:
            return "Unknown Error"
        }
    }
}
