//
//  selectepogitory.swift
//  iOSEngineerCodeCheck
//
//  Created by sakiyamaK on 2025/09/04.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
